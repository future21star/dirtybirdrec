class UsersController < ApplicationController
  include UsersHelper
  
  before_action :authenticate_user!, except: 
      [:index, :show, :parse_youtube, :artist, :announcements_feed,
        :interviews_feed, :videos_feed, :others_feed, :artists, :leaderboard,
        :load_more]
  before_action :set_notifications, only: [:leaderboard, :index, :show, :home, 
        :artist, :artists, :friends, :idols]

  def leaderboard
    @leader_users = leaderboard_query(1, 5, true)
    @badge_kinds = BadgeKind.all
  end

  def index
    @leader_users = leaderboard_query(params[:page] || 1, 9, true)
    @badge_kinds = BadgeKind.all
  end

  def load_more
    @leader_users = leaderboard_query(params[:page], 9, false)
    @badge_kinds = BadgeKind.all
  end

  def show
    @user = User.find(params[:id])
    fan_vars

    if @user.has_role? :artist
      redirect_to artist_path(@user) and return
    end

    @enricher = StreamRails::Enrich.new

    begin
      if current_user.present? && @user.id == current_user.id
        feed = StreamRails.feed_manager.get_news_feeds(@user.id)[:flat]
      else
        feed = StreamRails.feed_manager.get_user_feed(@user.id)
      end
    rescue Faraday::Error::ConnectionFailed
      results = []
    end

    results = feed.get()['results']
    @activities = @enricher.enrich_activities(results)

    # current_user.change_points( 'member over time' ) if current_user == @user
  end

  def home
    if current_user.subscription_type.blank?
      redirect_to choose_profile_path and return
    end

    redirect_to current_user
  end

  def update
    # TODO recheck for subscription_type
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)

    else
      logger.warn @user.errors.full_messages
    end

    respond_to do |format|
      format.js
      format.html { redirect_to home_path }
    end
  end

  def announcement_feed
    @user = current_user
    fan_vars

    begin
      feed = StreamRails.feed_manager.get_feed('announcement_user_feed', current_user.id)
      results = feed.get()['results']
    rescue Faraday::Error::ConnectionFailed
      results = []
    end

    @enricher = StreamRails::Enrich.new
    @activities = @enricher.enrich_activities(results)

    render :show
  end

  def release_feed
    @user = current_user
    fan_vars

    begin
      feed = StreamRails.feed_manager.get_feed('release_user_feed', current_user.id)
      results = feed.get()['results']
    rescue Faraday::Error::ConnectionFailed
      results = []
    end

    @enricher = StreamRails::Enrich.new
    @activities = @enricher.enrich_activities(results)

    render :show
  end

  def chirp_feed
    @user = current_user
    fan_vars

    get_feed_from @user.posts_from_followed_topics, 'Comment', 'topic'

    render :show
  end

  def artists_feed
    @user = current_user
    fan_vars

    begin
      feed = StreamRails.feed_manager.get_news_feeds(@user.id)[:flat]
      results = feed.get()['results']
    rescue Faraday::Error::ConnectionFailed
      results = []
    end

    @enricher = StreamRails::Enrich.new
    @activities = @enricher.enrich_activities(results).select { |a| a['actor'].has_role?(:artist) }

    render :show
  end

  def friends_feed
    @user = current_user
    fan_vars

    begin
      feed = StreamRails.feed_manager.get_news_feeds(@user.id)[:flat]
      results = feed.get()['results']
    rescue Faraday::Error::ConnectionFailed
      results = []
    end

    @enricher = StreamRails::Enrich.new
    @activities = @enricher.enrich_activities(results).select { |a| a['actor'].has_role?(:fan) }

    render :show
  end

  def choose_profile
  end

  def artist
    @user = User.find(params[:id])

    unless @user.has_role? :artist
      redirect_to user_path(@user) and return
    end

    begin
      feed = StreamRails.feed_manager.get_user_feed(@user.id)
      results = feed.get()['results']
    rescue Faraday::Error::ConnectionFailed
      results = []
    end
    @enricher = StreamRails::Enrich.new
    @activities = @enricher.enrich_activities(results)

    artist_vars
  end

  def interviews_feed
    @user = User.find(params[:id])
    artist_vars

    get_feed_from @user.announcements, "Announcement"

    render :home
  end

  def videos_feed
    @user = User.find(params[:id])
    artist_vars

    get_feed_from @user.videos, "Addvideo"

    render :home
  end

  def others_feed
    @user = User.find(params[:id])
    artist_vars

    begin
      feed = StreamRails.feed_manager.get_notification_feed(@user.id)
      results = feed.get()['results']
    rescue Faraday::Error::ConnectionFailed
      results = []
    end
    
    unseen = results.select { |r| r['is_seen'] == false }
    @unseen_count = unseen.count
    @enricher = StreamRails::Enrich.new

    if @unseen_count <= 8
      @activities = @enricher.enrich_aggregated_activities(results[0..7])
    else
      @activities = @enricher.enrich_aggregated_activities(unseen)
    end

    if @user.has_role?(:artist)
      render :artist 
    else
      render :show
    end
  end

  def artist_vars
    @followers = @user.followers
    @releases = @user.releases.released.limit(30)
    @artist_video = @user.videos.last
    @followed_users = @user.followed_users.with_role(:fan).limit(4)
    @followed_artists = @user.followed_users.with_role(:artist).limit(4)
  end

  def fan_vars
    @followed_users = @user.followed_users.with_role(:fan).limit(4)
    @followed_artists = @user.followed_users.with_role(:artist).limit(4)

    if @user.has_role? :admin
      @user_position = 0
    elsif @user.badge_points.blank?
      @user_position = ''
    else
      @user_position = User
          .joins('LEFT OUTER JOIN badge_points on (users.id = badge_points.user_id)')
          .group('users.id')
          .order('users.created_at ASC, SUM(badge_points.value) DESC')
          .count.keys.index(@user.id) + 1
    end
  end

  def get_feed_from objects, verb, target
    results = objects.map do |object|
      {
        'actor' => @user,
        'object' => object,
        'target' => object.try(target.to_sym),
        'verb' => verb,
        'foreign_id' => "#{verb}:#{object.id}",
        'time' => object.created_at
      }
    end
      
    @enricher = StreamRails::Enrich.new
    @activities = @enricher.enrich_activities(results)
  end

  def artists
    @artists = User.with_role :artist
  end

  def friends
    @user = User.find(params[:id])
    @friends = @user.followed_users.with_role(:fan)
  end

  def idols
    @user = User.find(params[:id])
    @idols = @user.followed_users.with_role(:artist)
  end

  private

    def user_params
      params.require(:user).permit(:avatar, :avatar_cache, :shipping_address, 
        :birthdate, :gender, :t_shirt_size, :city, #:subscription, 
        :subscription_type, :crop_x, :crop_y, :crop_w, :crop_h)
    end
end

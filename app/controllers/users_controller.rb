class UsersController < ApplicationController
  before_action :authenticate_user!, except: 
      [:index, :show, :parse_youtube, :artist, :announcements_feed,
        :interviews_feed, :videos_feed, :others_feed, :artists]

  def index
    @leader_users = User.with_role(:fan)
                        .includes(:badges)
                        .joins('LEFT OUTER JOIN badge_points on (users.id = badge_points.user_id)')
                        .group('users.id')
                        .order('users.created_at ASC, SUM(badge_points.value) DESC')
  end

  def show
    @user = User.find(params[:id])

    if @user.has_role? :artist
      redirect_to artist_path(@user) and return
    end

    feed = StreamRails.feed_manager.get_user_feed(@user.id)
    results = feed.get()['results']
    @enricher = StreamRails::Enrich.new
    @activities = @enricher.enrich_activities(results)

    @followed_users = @user.followed_users.with_role(:fan).limit(4)
    @followed_artists = @user.followed_users.with_role(:artist).limit(4)

    if @user.has_role? :admin
      @user_position = 0
    else
      @user_position = User.with_role(:fan)
          .joins('LEFT OUTER JOIN badge_points on (users.id = badge_points.user_id)')
          .group('users.id')
          .order('users.created_at ASC, SUM(badge_points.value) DESC')
          .count.keys.index(@user.id) + 1
    end

    current_user.change_points( 'member over time' ) if current_user == @user
  end

  def home
    if current_user.subscribtion_type.blank?
      redirect_to choose_profile_path and return
    end

    redirect_to current_user

    # feed = StreamRails.feed_manager.get_news_feeds(current_user.id)[:aggregated]
    # results = feed.get()['results']
    # @enricher = StreamRails::Enrich.new
    # @activities = @enricher.enrich_aggregated_activities(results)
  end

  def update
    user = User.find(params[:id])
    user.update_attributes(user_params)

    redirect_to home_path
  end

  def activity_feed
    #user_feed
    feed = StreamRails.feed_manager.get_user_feed(current_user.id)
    results = feed.get()['results']
    @enricher = StreamRails::Enrich.new
    @activities = @enricher.enrich_activities(results)

    render :home
  end

  def chrip_feed
    feed = StreamRails.feed_manager.get_news_feeds(current_user.id)[:aggregated]
    results = feed.get()['results']
    @enricher = StreamRails::Enrich.new
    @activities = @enricher.enrich_aggregated_activities(results)

    render :home
  end

  def release_feed
    feed = StreamRails.feed_manager.get_feed('release_user_feed', current_user.id)
    results = feed.get()['results']
    @enricher = StreamRails::Enrich.new
    @activities = @enricher.enrich_activities(results)

    render :home
  end

  def artist_feed
  end

  def choose_profile
  end

  def artist
    @artist = User.find(params[:id])

    unless @artist.has_role? :artist
      redirect_to users_path(@artist) and return
    end

    feed = StreamRails.feed_manager.get_user_feed(@artist.id)
    results = feed.get()['results']
    @enricher = StreamRails::Enrich.new
    @activities = @enricher.enrich_activities(results)

    artist_vars
  end

  def announcements_feed
    @artist = User.find(params[:id])
    artist_vars

    get_feed_from @artist.videos

    render :artist
  end

  def interviews_feed
    @artist = User.find(params[:id])
    artist_vars

    get_feed_from @artist.videos

    render :artist
  end

  def videos_feed
    @artist = User.find(params[:id])
    artist_vars

    get_feed_from @artist.videos

    render :artist
  end

  def others_feed
    @artist = User.find(params[:id])
    artist_vars

    get_feed_from @artist.videos

    render :artist
  end

  def artist_vars
    @followers = @artist.followers
    @releases = @artist.releases.released.limit(30)
    @artist_video = @artist.videos.last
  end

  def get_feed_from objects
    results = objects.map do |object|
      {
        'actor' => @artist,
        'object' => object,
        'verb' =>"Addvideo",
        'foreign_id' => "Addvideo:#{object.id}"
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
        :birthdate, :gender, :t_shirt_size, :subscription, :subscribtion_type)
    end
end

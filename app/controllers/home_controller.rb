class HomeController < ApplicationController
  include UsersHelper

  before_action :authenticate_user!, 
      except: [:index, :demo_index, :demo_login, :about, :birdfeed]
  before_action :set_notifications, only: [:about, :birdfeed]

  def index
    @slider = SliderImage.all.ordered

    @leader_users = leaderboard_query(1, 20, true)

    @artists = User.with_role(:artist)
                   .order('created_at ASC')
                   .includes(:artist_info)
                   .limit(20)

    @releases = Release.where(
      'published_at <= :now AND (published_at >= :user_max OR available_to_all = true)',
      now: DateTime.now,
      user_max: DateTime.now - 1.month
    ).order('published_at DESC')

    @badge_kinds = BadgeKind.all

    #TODO decrease count of queries
    # @leader_points = {}

    # @badge_points = BadgePoint.all.freeze

    # @leader_users.each do |user|
    #   @leader_points["leader_#{user.id}"] ||= {}
    #   @badge_kinds.each do |kind|
    #     @leader_points["leader_#{user.id}"]["kind#{kind.id}"] = @badge_points.where(user_id: user.id, badge_kind_id: kind.id).pluck(:value).sum
    #   end
    # end
  end

  def about
  end

  def birdfeed
    begin
      feed = StreamRails.feed_manager.get_feed('masterfeed', 1)
      results = feed.get()['results']
    rescue Faraday::Error::ConnectionFailed
      results = []
    end
    
    @enricher = StreamRails::Enrich.new
    @activities = @enricher.enrich_activities(results)
  end


  #======================#TODO demo remove=========================
  def demo_index
    @users = User.all.order(id: :asc)
    if current_user
      @other_user = @users.where.not(id: current_user.id).first

      begin
        feed = StreamRails.feed_manager.get_user_feed(@other_user.id)
        results = feed.get()['results']
      rescue Faraday::Error::ConnectionFailed
        results = []
      end
      
      @enricher = StreamRails::Enrich.new
      @activities = @enricher.enrich_activities(results)

      @releases = Release.limit(3)
      @posts = Post.all
      @topics = Topic.all
    end
  end

  def demo_login
    user = User.find params[:user_id]
    sign_in user

    redirect_to demo_path
  end

  def demo_drop
    user = User.find(params[:id])
    user.subscription_type = nil
    user.save

    redirect_to root_path
  end

  def demo_get_100_points
    # User.find(params[:id]).change_points( 100 )
    redirect_to demo_path
  end

end

class HomeController < ApplicationController
  include UsersHelper
  include StreamRails::Activity

  before_action :authenticate_user!, 
      except: [:index, :demo_index, :demo_login, :about, :birdfeed, :share]
  before_action :set_notifications, only: [:about, :birdfeed, :demo_index] #TODO remove demo_index

  def index
    @slider = SliderImage.all.ordered

    @leader_users = leaderboard_query(1, 20, true)

    @artists = User.with_role(:artist)
                   .order('created_at ASC')
                   .includes(:artist_info)
                   .limit(20)

    @releases = Release.published.where(
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

  def share
    if current_user
      feed = StreamRails.feed_manager.get_user_feed( current_user.id )

      if params[:subtype] && params[:subtype_id]
        target = "#{params[:subtype].capitalize}:#{params[:subtype_id]}"
      else
        target = ''
      end

      activity = {
        actor: "User:#{current_user.id}",
        verb: "Share",
        object: "#{params[:type].capitalize}:#{params[:type_id]}",
        foreign_id: "#{params[:type].capitalize}:#{params[:type_id]}",
        target: target,
        social: params[:social],
        time: DateTime.now.iso8601
      }
      feed.add_activity(activity)
    end

    render json: {}
  end


  #======================#TODO demo remove=========================
  def demo_index
    @users = User.all.order(id: :asc)
      @other_user = User.find 37079
    if current_user
      # @other_user = @users.where.not(id: current_user.id).first

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

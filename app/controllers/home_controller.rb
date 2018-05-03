class HomeController < ApplicationController
  before_action :authenticate_user!, 
      except: [:index, :demo_index, :demo_login, :about]

  def index
    @slider = SliderImage.all.ordered
    @leader_users = User.with_role(:fan)
                        .includes(:badges)
                        .joins('LEFT OUTER JOIN badge_points on (users.id = badge_points.user_id)')
                        .group('users.id')
                        .order('users.created_at ASC, SUM(badge_points.value) DESC')
                        .limit(20)
    @artists = User.with_role(:artist)
                   .order('created_at ASC')
                   .includes(:artist_info)
                   .limit(20)
    @releases = Release.released.limit(30)

    @badge_kinds = BadgeKind.all

    # @leader_points = {}

    # @badge_points = BadgePoint.all.freeze

    # logger.warn "++++++++++++++++"
    # logger.warn @badge_points

    # @leader_users.each do |user|
    #   @leader_points["leader_#{user.id}"] ||= {}
    #   @badge_kinds.each do |kind|
    #     @leader_points["leader_#{user.id}"]["kind#{kind.id}"] = @badge_points.where(user_id: user.id, badge_kind_id: kind.id).pluck(:value).sum
    #   end
    # end
  end

  def about
  end

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
    User.find(params[:id]).change_points( 100 )
    redirect_to demo_path
  end

end

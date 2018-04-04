class HomeController < ApplicationController
  before_action :authenticate_user!, 
      except: [:index, :demo_index, :demo_login, :about]

  def index
    @slider = SliderImage.all.ordered
    @leader_users = User.with_role(:fan).includes(:badges).order(points: :desc).limit(20)
    @artists = User.with_role(:artist).order(points: :desc).limit(20)
    @releases = Release.released
  end

  def about
  end

  def demo_index
    @users = User.all.order(id: :asc)
    if current_user
      feed = StreamRails.feed_manager.get_user_feed(@users.where.not(id: current_user.id).first.id)
      results = feed.get()['results']
      @enricher = StreamRails::Enrich.new
      @activities = @enricher.enrich_activities(results)

      @releases = Release.all
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
    user.subscribtion_type = nil
    user.save

    redirect_to root_path
  end

  def demo_get_100_points
    User.find(params[:id]).change_points( 100 )
    redirect_to demo_path
  end

end

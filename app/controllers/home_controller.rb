class HomeController < ApplicationController
  before_action :authenticate_user!, except: [:index, :demo_index, :demo_login]
  helper_method :resource_name, :resource, :devise_mapping, :resource_class

  def resource_name
    :user
  end
  
  def resource
    @resource ||= User.new
  end

  def resource_class
    User
  end
  
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end




  def index
    @slider = SliderImage.all.ordered
    @leader_users = User.all.order(created_at: :asc).limit(3)
    @users = User.all.order(created_at: :desc).limit(3)
    @release = Release.last
  end

  def about
  end

  def chrip
    
  end

  def demo_index
    @users = User.all.order(id: :asc).limit(2)
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

end

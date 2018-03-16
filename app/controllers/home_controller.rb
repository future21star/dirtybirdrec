class HomeController < ApplicationController
  def index
    @slider = SliderImage.all.ordered
  end

  def about
  end

  def demo_index
    @users = User.all.order(id: :asc).limit(2)
    if current_user
      feed = StreamRails.feed_manager.get_news_feeds(@users.where.not(id: current_user.id).first.id)[:flat]
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

end

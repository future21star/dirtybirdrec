class UsersController < ApplicationController
  before_action :authenticate_user!


  def index
    @users = User.all.order(created_at: :desc)
  end

  def show
    @user = User.find(params[:id])

    feed = StreamRails.feed_manager.get_user_feed(current_user.id)
    results = feed.get()['results']
    @enricher = StreamRails::Enrich.new
    @activities = @enricher.enrich_activities(results)
  end

  def home
    if current_user.subscribtion_type.blank?
      redirect_to choose_profile_users_path and return
    end

    feed = StreamRails.feed_manager.get_news_feeds(current_user.id)[:aggregated]
    results = feed.get()['results']
    @enricher = StreamRails::Enrich.new
    @activities = @enricher.enrich_aggregated_activities(results)
  end

  def update
    user = User.find(params[:id])
    user.update_attributes(user_params)

    redirect_to home_users_path
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

  def track_feed
    #track_feed
    feed = StreamRails.feed_manager.get_news_feeds(current_user.id)[:track]
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
  end

  private

    def user_params
      params.require(:user).permit(:avatar, :avatar_cache, :shipping_address, 
        :birthdate, :gender, :t_shirt_size, :subscription, :subscribtion_type)
    end
end

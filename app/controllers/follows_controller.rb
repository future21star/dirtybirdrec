class FollowsController < ApplicationController
  before_action :authenticate_user!
  
  def create
    follow = Follow.new(follow_params)
    follow.user = current_user

    if follow.save
      if follow.followable_type == "User"
        StreamRails.feed_manager.follow_user(follow.user_id, follow.followable_id)
      else
        feed = StreamRails.feed_manager.get_feed( follow.followable_type.downcase, follow.followable_id )
        user_feed = StreamRails.feed_manager
            .get_feed( "#{follow.followable_type.downcase}_user_feed", follow.user_id)
        user_feed.follow(feed.slug, follow.followable_id)
      end
    end

    render 'toggle_follow', locals: {
              target: follow, 
              text: JSON.parse( params[:text] ), 
              classes: params[:classes] } 
  end

  def destroy
    follow = Follow.find_by_id(params[:id])

    return unless follow

    if follow.user_id == current_user.id
      follow.destroy!

      if follow.followable_type == "User"
        StreamRails.feed_manager.unfollow_user(follow.user_id, follow.followable_id)
      else
        feed = StreamRails.feed_manager.get_feed( fillow.followable_type.downcase, fillow.followable_id )
        user_feed = StreamRails.feed_manager
            .get_feed( "#{fillow.followable_type.downcase}_user_feed", fillow.user_id)
        user_feed.unfollow(feed.slug, fillow.user_id)
      end
    end

    render 'toggle_follow', locals: {
              target: follow, 
              text: JSON.parse( params[:text] ), 
              classes: params[:classes] } 
  end

  private
    def follow_params
      params.permit(:followable_id, :followable_type)
    end

end
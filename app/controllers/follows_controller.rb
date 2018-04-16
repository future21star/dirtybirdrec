class FollowsController < ApplicationController
  before_action :authenticate_user!
  
  def create
    follow = Follow.new(follow_params)
    follow.user = current_user
    if follow.save
      StreamRails.feed_manager.follow_user(follow.user_id, follow.followable_id)
    end
    session[:return_to] ||= request.referer
    redirect_to session.delete(:return_to)
  end

  def destroy
    follow = Follow.find_by_id(params[:id])
    redirect_back(fallback_location: root_path) and return unless follow

    if follow.user_id == current_user.id
      follow.destroy!
      StreamRails.feed_manager.unfollow_user(follow.user_id, follow.followable_id)
    end
    session[:return_to] ||= request.referer
    redirect_to session.delete(:return_to)
  end

  private
    def follow_params
      params.permit(:followable_id, :followable_type)
    end

end
class LikesController < ApplicationController
  before_action :authenticate_user!

  def create
    like = Like.new(like_params)
    like.user_id = current_user.id
    like.save

    render 'toggle_like', locals: { like: like, style: params[:style] }
  end

  def destroy
    like = Like.find(params[:id]).destroy

    render 'toggle_like', locals: { like: like, style: params[:style] }
  end

  private

    def like_params
      params.permit(:likeable_type, :likeable_id)
    end
end

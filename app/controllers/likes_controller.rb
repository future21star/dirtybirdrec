class LikesController < ApplicationController

  def create
    like = Like.new(like_params)
    like.user_id = current_user.id
    like.save

    redirect_back(fallback_location: root_path)
    # render 'toggle_like', locals: { like: like}
  end

  def destroy
    like = Like.find(params[:id]).destroy

    redirect_back(fallback_location: root_path)
    # render 'toggle_like', 
    #     locals: {likeable_type: like.likeable_type, likeable_id: like.likeable_id}
  end

  private

    def like_params
      params.permit(:likeable_type, :likeable_id)
    end
end

class CommentsController < ApplicationController
before_action :authenticate_user!

  def create
    comment = Comment.new(comment_params)
    comment.user_id = current_user.id

    logger.warn(comment.errors.inspect) unless comment.save

    redirect_back(fallback_location: root_path)
  end

  private

    def comment_params
      params.require(:comment).permit(:commentable_type, :commentable_id, 
        :body, :title, :parent_id, :likes_count, :comments_count,
        :shares_count)
    end
end

class CommentsController < ApplicationController
  def create
    comment = Comment.new(comment_params)
    comment.user_id = current_user.id

    logger.warn(comment.errors.inspect) unless comment.save

    redirect_to demo_path
  end

  private

    def comment_params
      params.require(:comment).permit(:commentable_type, :commentable_id, :body)
    end
end

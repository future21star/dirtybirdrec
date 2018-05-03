class CommentsController < ApplicationController
before_action :authenticate_user!

  def create
    @comment = Comment.new(comment_params)

    if @comment.commentable_type == "User" &&
            @comment.parent.nil? &&
            @comment.commentable_id != current_user.id
      redirect_back(fallback_location: root_path) and return
    end

    @comment.user_id = current_user.id

    logger.warn(@comment.errors.full_messages) unless @comment.save

  end

  private

    def comment_params
      params.require(:comment).permit(:commentable_type, :commentable_id, 
        :body, :title, :parent_id, :likes_count, :comments_count,
        :shares_count)
    end
end

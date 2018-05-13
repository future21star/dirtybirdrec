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
 
  def reply_form
    @comment_id = params[:comment_id]
    @commentable_id = params[:commentable_id]
    @commentable_type = params[:commentable_type]
    @comment_hash = SecureRandom.hex
    @new_comment = Comment.new
  end


  private

    def comment_params
      params.require(:comment).permit(:commentable_type, :commentable_id, 
        :body, :title, :parent_id, :likes_count, :shares_count, :comment_hash)
    end
end

class PostsController < ApplicationController
  before_action :authenticate_user!
  
  def create
    @topic = Topic.find(params[:post][:topic_id])
    @post = Post.new(post_params)
    @post.user_id = current_user.id
    if @post.save
      flash[:notice] = 'Post was created'
    else
      flash[:alert] = @post.errors.full_messages.join(', ')
    end
  end

  def reply_form
    @post_id = params[:post_id]
    @topic_id = params[:topic_id]
    @post_hash = SecureRandom.hex
    @post = Post.new
  end

  protected

    def post_params
      params.require(:post).permit(:text, :topic_id, :parent_id, :post_hash)
    end
end

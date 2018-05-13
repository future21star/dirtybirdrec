class TopicsController < ApplicationController
  before_action :authenticate_user!
  
  breadcrumb 'Categories', :chirp_index_path, match: :exact

  def show
    @topic = Topic.find(params[:id])
    if params[:chirp_id].present?
      @category = TopicCategory.find(params[:chirp_id])
    else
      @category = @topic.category
    end
    @new_post = Post.new

    breadcrumb @category.title, chirp_path(@category), match: :exact
    breadcrumb @topic.title, chirp_topic_path(@category, @topic), match: :exact
  end

  def create
    topic = Topic.new(topic_params)
    topic.user_id = current_user.id
    if topic.save
      flash[:notice] = 'Topic was created'
    else
      flash[:alert] = topic.errors.full_messages.join(', ')
    end

    redirect_to chirp_path(topic.category)
  end

  def topic_params
    params.require(:topic).permit(:text, :title, :category_id)
  end
end

class TopicCategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notifications, only: [:show, :index]

  breadcrumb 'Categories', :chirp_index_path, match: :exact


  def index
    @groups = TopicCategoryGroup.all
  end

  def show
    @category = TopicCategory.find(params[:id])
    @topic = Topic.new

    breadcrumb @category.title, chirp_path(@category), match: :exact
  end
end

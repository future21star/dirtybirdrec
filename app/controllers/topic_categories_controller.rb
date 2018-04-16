class TopicCategoriesController < ApplicationController
  before_action :authenticate_user!
  
  breadcrumb 'Categories', :chirp_index_path, match: :exact


  def index
    @groups = TopicCategoryGroup.all
  end

  def show
    @category = TopicCategory.find(params[:id])

    breadcrumb @category.title, chirp_path(@category), match: :exact
  end
end

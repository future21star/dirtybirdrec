require 'test_helper'

class TopicCategoriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get topic_categories_index_url
    assert_response :success
  end

  test "should get show" do
    get topic_categories_show_url
    assert_response :success
  end

end

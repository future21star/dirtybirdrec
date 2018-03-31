require 'test_helper'

class TracksControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get tracks_show_url
    assert_response :success
  end

end

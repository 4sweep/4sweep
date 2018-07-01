require 'test_helper'

class ExplorerControllerTest < ActionController::TestCase
  test "should get explore" do
    get :explore
    assert_response :success
  end

end

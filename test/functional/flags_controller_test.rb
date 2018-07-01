require 'test_helper'

class FlagsControllerTest < ActionController::TestCase
  test "should get list" do
    get :list
    assert_response :success
  end

  test "should get submit" do
    get :submit
    assert_response :success
  end

  test "should get check" do
    get :check
    assert_response :success
  end

end

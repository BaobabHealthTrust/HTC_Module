require 'test_helper'

class CounselorControllerTest < ActionController::TestCase
  test "should get test_details" do
    get :test_details
    assert_response :success
  end

  test "should get sample" do
    get :sample
    assert_response :success
  end

  test "should get final_result" do
    get :final_result
    assert_response :success
  end

end

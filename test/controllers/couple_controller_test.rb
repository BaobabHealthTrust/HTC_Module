require 'test_helper'

class CoupleControllerTest < ActionController::TestCase
  test "should get status" do
    get :status
    assert_response :success
  end

  test "should get testing" do
    get :testing
    assert_response :success
  end

  test "should get counseling" do
    get :counseling
    assert_response :success
  end

  test "should get assessment" do
    get :assessment
    assert_response :success
  end

  test "should get appointment" do
    get :appointment
    assert_response :success
  end

end

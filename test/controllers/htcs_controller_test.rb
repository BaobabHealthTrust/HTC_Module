require 'test_helper'

class HtcsControllerTest < ActionController::TestCase
  setup do
    @htc = htcs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:htcs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create htc" do
    assert_difference('Htc.count') do
      post :create, htc: {  }
    end

    assert_redirected_to htc_path(assigns(:htc))
  end

  test "should show htc" do
    get :show, id: @htc
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @htc
    assert_response :success
  end

  test "should update htc" do
    patch :update, id: @htc, htc: {  }
    assert_redirected_to htc_path(assigns(:htc))
  end

  test "should destroy htc" do
    assert_difference('Htc.count', -1) do
      delete :destroy, id: @htc
    end

    assert_redirected_to htcs_path
  end
end

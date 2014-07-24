require 'test_helper'

class ObsControllerTest < ActionController::TestCase
  setup do
    @ob = obs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:obs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ob" do
    assert_difference('Ob.count') do
      post :create, ob: {  }
    end

    assert_redirected_to ob_path(assigns(:ob))
  end

  test "should show ob" do
    get :show, id: @ob
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ob
    assert_response :success
  end

  test "should update ob" do
    patch :update, id: @ob, ob: {  }
    assert_redirected_to ob_path(assigns(:ob))
  end

  test "should destroy ob" do
    assert_difference('Ob.count', -1) do
      delete :destroy, id: @ob
    end

    assert_redirected_to obs_path
  end
end

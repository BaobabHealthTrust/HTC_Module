require 'test_helper'

class LocationTagsControllerTest < ActionController::TestCase
  setup do
    @location_tag = location_tags(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:location_tags)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create location_tag" do
    assert_difference('LocationTag.count') do
      post :create, location_tag: {  }
    end

    assert_redirected_to location_tag_path(assigns(:location_tag))
  end

  test "should show location_tag" do
    get :show, id: @location_tag
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @location_tag
    assert_response :success
  end

  test "should update location_tag" do
    patch :update, id: @location_tag, location_tag: {  }
    assert_redirected_to location_tag_path(assigns(:location_tag))
  end

  test "should destroy location_tag" do
    assert_difference('LocationTag.count', -1) do
      delete :destroy, id: @location_tag
    end

    assert_redirected_to location_tags_path
  end
end

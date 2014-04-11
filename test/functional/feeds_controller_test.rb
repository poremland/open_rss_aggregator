require 'test_helper'

class FeedsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get all" do
    get :all
    assert_response :success
  end

  test "should get tree" do
    get :tree
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get sync" do
    get :sync
    assert_response :success
  end

  test "should get unread_feed_items" do
    get :unread_feed_items
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit" do
    get :edit
    assert_response :success
  end

  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get update" do
    get :update
    assert_response :success
  end

  test "should get remove" do
    get :remove
    assert_response :success
  end

  test "should get mark_items_as_read" do
    get :mark_items_as_read
    assert_response :success
  end

end

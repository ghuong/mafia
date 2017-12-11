require 'test_helper'

# Test to make sure users are redirected to the right places
class RoomsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @pregame_room_code = rooms(:pregame_room).code
    @playing_room_code = rooms(:playing_room).code
    @finished_room_code = rooms(:finished_room).code
    @nonexistent_room_code = "0000"
    @host_user = users(:host_user)
    @guest_user = users(:guest_user)
  end

  test "should get new" do
    get new_room_path
    assert_response :success
  end

  test "should redirect show when joining room for the first time" do
    get room_path(@pregame_room_code)
    assert_redirected_to new_user_url(@pregame_room_code)
  end

  test "should get show when re-joining room as guest" do
    authenticate_as(@guest_user, @pregame_room_code)
    get room_path(@pregame_room_code)
    assert_response :success
  end

  test "should redirect show when re-joining room as host" do
    authenticate_as(@host_user, @pregame_room_code)
    get room_path(@pregame_room_code)
    assert_redirected_to edit_settings_path(@pregame_room_code)
  end

  test "should redirect show when game already started" do
    get room_path(@playing_room_code)
    assert_response :redirect
  end

  test "should redirect show when game already finished" do
    get room_path(@finished_room_code)
    assert_response :redirect
  end

  test "should show when game non-existent" do
    get room_path(@nonexistent_room_code)
    assert_select 'div#error_explanation'
  end

end

require 'test_helper'

class RoomsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @pregame_room_code = rooms(:pregame_room).code
  end

  test "should get new" do
    get new_room_path
    assert_response :success
  end

  test "should redirect from show when joining room for the first time" do
    get room_path(@pregame_room_code)
    assert_redirected_to new_user_url(@pregame_room_code)
  end

end

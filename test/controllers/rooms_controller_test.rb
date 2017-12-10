require 'test_helper'

class RoomsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @pregame_room_code = rooms(:pregame_room).code
  end

  test "should get new" do
    get new_room_path
    assert_response :success
  end

  test "should get show" do
    get room_path(@pregame_room_code)
    assert_response :success
  end

end

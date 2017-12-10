require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @pregame_room_code = rooms(:pregame_room).code
  end

  test "should get new" do
    get new_user_path(@pregame_room_code)
    assert_response :success
  end

end

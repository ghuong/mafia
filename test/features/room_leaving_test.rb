require 'test_helper'

class RoomLeavingTest < ActionDispatch::IntegrationTest
  test "it allows guests to leave room" do    
    room_code = ""
    within_session :hosts_window do
      room_code = create_room("Ryan")
    end

    guest_name = "John"
    join_room(room_code, guest_name)
    assert_difference "User.count", -1 do
      page.driver.submit :delete, users_path(room_code), {}
    end
    assert_equal root_path, current_path

    within_session :hosts_window do
      refresh_page
      assert_not page.has_css?('li', text: guest_name)
    end
  end
end
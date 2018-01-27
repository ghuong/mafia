require 'test_helper'

class RoomCreationTest < ActionDispatch::IntegrationTest
  test "it creates a room" do
    room_code = ""
    host_name = "Richard Rich"
    # Creates a new User and Room
    assert_difference ['User.count', 'Room.count'], 1 do
      room_code = create_room(host_name)
    end

    assert_equal 200, page.status_code
    assert_equal edit_settings_path(room_code), current_path
    assert page.has_content?(room_code)

    within('#users-list') do
      assert page.has_css?('li', text: host_name)
    end

    # Try to leave room, it won't let you
    visit root_path
    assert_equal 200, page.status_code
    assert_equal edit_settings_path(room_code), current_path
  end
end
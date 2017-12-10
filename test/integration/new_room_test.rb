require 'test_helper'

class NewRoomTest < ActionDispatch::IntegrationTest
  test "create new room" do
    # Get new room page
    get new_room_path
    assert_template 'rooms/new'
    # Submit form with name
    assert_difference 'User.count', 1 do
      post rooms_path,
           params: { user: { name: "James" } }
    end
    room = assigns(:room)
    # Should be redirected to the settings page
    assert_redirected_to edit_settings_path(room.code)
    follow_redirect!
    assert_template 'settings/edit'
    # Ensure page displays the room code
    assert_select "p", "#{room.code}"
  end
end

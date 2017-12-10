require 'test_helper'

class NewRoomTest < ActionDispatch::IntegrationTest
  test "create new room" do
    # Get new room page
    get new_room_path
    assert_template 'rooms/new'
    # Submit form with name
    post rooms_path,
         params: { user: { name: "James" } }
    room = assigns(:room)
    # Should be redirected to the settings page
    assert_redirected_to edit_settings_path(room.code)
    follow_redirect!
    assert_template 'settings/edit'
  end
end

require 'test_helper'

class RoomJoiningTest < ActionDispatch::IntegrationTest
  test "it allows guests to join room" do
    room_code = ""
    host_name = "George"
    within_session :hosts_window do
      room_code = create_room(host_name)
    end

    # Joining with duplicate name should fail
    assert_difference 'User.count', 0 do
      join_room(room_code, host_name)
    end
    assert page.has_css?('div#error_explanation')
    assert page.has_css?('div.field_with_errors')

    # Joining with unique name should succeed
    guest_name = "Lisa"
    assert_differences [['User.count', 1], ['Room.count', 0]] do
      join_room(room_code, guest_name)
    end
    assert_equal 200, page.status_code
    assert_equal room_path(room_code), current_path
    assert page.has_content?(room_code)

    within('#users-list') do
      assert page.has_css?('li', text: host_name)
      assert page.has_css?('li', text: guest_name)
    end

    # Host's user list is updated
    within_session :hosts_window do
      refresh_page
      assert page.has_css?('li', text: guest_name)
    end

    # Try to leave room, won't let you
    visit root_path
    assert_equal 200, page.status_code
    assert_equal room_path(room_code), current_path
  end
end
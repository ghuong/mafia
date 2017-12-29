require 'test_helper'

class StartGameTest < ActionDispatch::IntegrationTest
  test "it can start game" do
    room_code = create_room

    # Add two roles
    select MAFIA_ROLES[1], from: "role"
    click_on "add-role"
    select MAFIA_ROLES[0], from: "role"
    click_on "add-role"

    # Try to start game, should fail
    click_on "start-game"
    assert_equal edit_settings_path(room_code), current_path

    # New guest joins
    within_session :guests_window do
      join_room(room_code, "Lauren")
    end

    # Try to start again, should succeed
    click_on "start-game"
    assert_equal edit_actions_path(room_code), current_path

    within_session :guests_window do
      refresh_page
      assert_equal edit_actions_path(room_code), current_path
    end
  end
end
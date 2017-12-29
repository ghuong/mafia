require 'test_helper'

class StartGameTest < ActionDispatch::IntegrationTest
  test "it can start game" do
    room_code = create_room

    # Add four roles
    select MAFIA_ROLES[1], from: "role"
    click_on "add-role"
    select MAFIA_ROLES[0], from: "role"
    click_on "add-role"
    select MAFIA_ROLES[1], from: "role"
    click_on "add-role"
    select MAFIA_ROLES[0], from: "role"
    click_on "add-role"

    # Try to start game, should fail
    click_on "start-game"
    assert_equal edit_settings_path(room_code), current_path

    # New guests join
    within_session :guest_1_window do
      join_room(room_code, "Lauren")
    end

    within_session :guest_2_window do
      join_room(room_code, "Kyle")
    end

    within_session :guest_3_window do
      join_room(room_code, "Marcel")
    end

    # Try to start again, should succeed
    click_on "start-game"
    assert_equal edit_actions_path(room_code), current_path
    role = find('#role')['name']

    # Count the roles
    role_counts = [0, 0]
    if role == "Mafia"
      role_counts[1] += 1
    elsif role == "Villager"
      role_counts[0] += 1
    end

    [:guest_1_window, :guest_2_window, :guest_3_window].each do |window|
      within_session window do
        refresh_page
        assert_equal edit_actions_path(room_code), current_path
        role = find('#role')['name']
        if role == "Mafia"
          role_counts[1] += 1
        elsif role == "Villager"
          role_counts[0] += 1
        end
      end
    end

    assert_equal 2, role_counts[0]
    assert_equal 2, role_counts[1]
  end
end
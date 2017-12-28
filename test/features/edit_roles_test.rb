require 'test_helper'

class EditRolesTest < ActionDispatch::IntegrationTest
  test "it can add and remove roles" do
    room_code = create_room
    select MAFIA_ROLES[1], from: "role"

    within('#roles-list') do
      assert_not page.has_css?('li', text: MAFIA_ROLES[1])
    end

    within_session :guests_window do
      join_room(room_code, "Helen")

      within('#roles-list') do
        assert_not page.has_css?('li', text: MAFIA_ROLES[1])
      end
    end

    click_on "add-role"

    assert_equal 200, page.status_code
    assert_equal edit_settings_path(room_code), current_path
    within('#roles-list') do
      assert page.has_css?('li', text: MAFIA_ROLES[1])
    end

    within_session :guests_window do
      refresh_page
      within('#roles-list') do
        assert page.has_css?('li', text: MAFIA_ROLES[1])
      end
    end
  end
end
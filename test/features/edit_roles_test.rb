require 'test_helper'

class EditRolesTest < ActionDispatch::IntegrationTest
  test "it can add and remove roles" do
    room_code = create_room

    # No roles added yet
    assert_not page.has_css?('#roles-list')

    # Guest user sees no roles too
    within_session :guests_window do
      join_room(room_code, "Helen")

      assert_not page.has_css?('#roles-list')
    end

    # Add new role
    select MAFIA_ROLES[1][:name], from: "role"
    click_on "add-role"
    assert_equal 200, page.status_code
    assert_equal edit_settings_path(room_code), current_path
    # Should see new role
    within('#roles-list') do
      assert page.has_css?('li', text: MAFIA_ROLES[1][:name])
      assert page.has_css?('a', id: 'remove-role-1')
    end

    # Guest user should see new role too
    within_session :guests_window do
      refresh_page
      within('#roles-list') do
        assert page.has_css?('li', text: MAFIA_ROLES[1][:name])
        assert_not page.has_css?('a', id: 'remove-role-1')
      end
    end

    # Add another role
    select MAFIA_ROLES[0][:name], from: "role"
    click_on "add-role"

    # Remove role first role added
    click_on "remove-role-1"

    within('#roles-list') do
      assert page.has_css?('li', text: MAFIA_ROLES[0][:name])
      assert page.has_css?('a', id: 'remove-role-0')
      
      assert_not page.has_css?('li', text: MAFIA_ROLES[1][:name])
    end

    # Guest user should see new role, but not first deleted one
    within_session :guests_window do
      refresh_page
      within('#roles-list') do
        assert page.has_css?('li', text: MAFIA_ROLES[0][:name])
        assert_not page.has_css?('a', id: 'remove-role-0')

        assert_not page.has_css?('li', text: MAFIA_ROLES[1][:name])
      end
    end
  end
end
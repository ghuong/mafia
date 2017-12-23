require 'test_helper'

class RoomCreationTest < ActionDispatch::IntegrationTest
  def test_it_creates_a_room
    visit root_path
    click_on 'new-room'
    fill_in 'name', with: 'Richard'

    # Creates a new User and Room
    assert_difference ['User.count', 'Room.count'], 1 do
      click_on 'submit'
    end

    # Get Room Code from the URL
    room_code = current_path.split('/')[2]
    assert_equal 200, page.status_code
    assert_equal edit_settings_path(room_code), current_path
    assert page.has_content?(room_code)

    within('#users-list') do
      assert page.has_css?('li', text: 'Richard')
    end

    # Rejoin room
    visit room_path(room_code)
    assert_equal 200, page.status_code
    assert_equal edit_settings_path(room_code), current_path
  end
end
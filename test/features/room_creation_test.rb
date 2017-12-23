require 'test_helper'

class RoomCreationTest < ActionDispatch::IntegrationTest
  def test_it_creates_a_room
    visit root_path
    click_on 'new-room'
    fill_in 'name', with: 'Richard'
    click_on 'submit'
    within('#users-list') do
      assert page.has_css?('li', text: 'Richard')
    end
  end
end
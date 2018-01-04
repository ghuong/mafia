require 'test_helper'

class GameEndTest < ActionDispatch::IntegrationTest

  def setup
    @room_code = create_room("Host")

    # Add four roles
    select "Mafia", from: "role"
    click_on "add-role"
    select "Villager", from: "role"
    click_on "add-role"
    select "Villager", from: "role"
    click_on "add-role"
    select "Villager", from: "role"
    click_on "add-role"
    select "Villager", from: "role"
    click_on "add-role"

    # New guests join
    within_session :guest_1 do
      join_room(@room_code, "Lauren")
    end

    within_session :guest_2 do
      join_room(@room_code, "Kyle")
    end

    within_session :guest_3 do
      join_room(@room_code, "Marcel")
    end

    within_session :guest_4 do
      join_room(@room_code, "Roger")
    end

    click_on "start-game"
  end

  test "mafia can win" do
    mafia = ''
    villagers = []
    windows = [:default, :guest_1, :guest_2, :guest_3, :guest_4]

    # Determine who are the villagers
    windows.each do |window|
      within_session window do
        refresh_page

        if page.has_css?('#role', text: "Mafia")
          mafia = find('#user').text
        else
          villagers << find('#user').text
        end
      end
    end

    # Night 1 - Mafia kills a villager
    windows.each do |window|
      within_session window do
        if edit_actions_path(@room_code) == current_path
          click_on 'submit-actions'
        end
      end
    end
    villagers.shift

    # Day actions
    windows.each do |window|
      within_session window do
        visit edit_actions_path(@room_code)

        if edit_actions_path(@room_code) == current_path
          select villagers[0]
          click_on 'submit-actions'
        end
      end
    end

    # Night actions
    windows.each do |window|
      within_session window do
        visit edit_actions_path(@room_code)

        if edit_actions_path(@room_code) == current_path
          click_on 'submit-actions'
        end
      end
    end

    # Mafia wins
    windows.each do |window|
      within_session window do
        visit edit_actions_path(@room_code)
        assert page.has_content?('Game Over')
      end
    end
  end

  test "villagers can win" do
    mafia = ''
    villagers = []
    windows = [:default, :guest_1, :guest_2, :guest_3, :guest_4]

    # Determine who are the villagers
    windows.each do |window|
      within_session window do
        refresh_page

        if page.has_css?('#role', text: "Mafia")
          mafia = find('#user').text
        else
          villagers << find('#user').text
        end
      end
    end

    # Night 1 - Mafia kills a villager
    windows.each do |window|
      within_session window do
        if edit_actions_path(@room_code) == current_path
          click_on 'submit-actions'
        end
      end
    end
    villagers.shift

    # Day actions
    windows.each do |window|
      within_session window do
        visit edit_actions_path(@room_code)

        if edit_actions_path(@room_code) == current_path
          select mafia
          click_on 'submit-actions'
        end
      end
    end

    # Villagers win
    windows.each do |window|
      within_session window do
        visit edit_actions_path(@room_code)
        assert page.has_content?('Game Over')
      end
    end
  end
end






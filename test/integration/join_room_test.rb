require 'test_helper'

class JoinRoomTest < ActionDispatch::IntegrationTest

  def setup
    @host_user = users(:host_user)
    @user_in_finished_room = users(:user_in_finished_room)
    @nonexistent_room_code = "0000"
    @pregame_room_code = rooms(:pregame_room).code
    @finished_room_code = rooms(:finished_room).code
    @playing_room_code = rooms(:playing_room).code
  end

  test "cannot join non-existent room" do
    get room_path(@nonexistent_room_code)
    assert_template 'static_pages/home'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  test "can view game verdict as player" do
    post join_path,
         params: { room_code: @finished_room_code,
                   user_id: @user_in_finished_room.id,
                   remember_token: 'my_token' }
    assert_redirected_to verdict_path(@finished_room_code)
    follow_redirect!
    assert_template 'verdicts/show'
  end

  test "cannot join game in-progress" do
    get room_path(@playing_room_code)
    follow_redirect!
    assert_template 'static_pages/home'
    assert_not flash.empty?
  end

  test "can join new game" do
    get root_path
    # Join existing room with its Room Code
    post join_path,
         params: { room: { code: @pregame_room_code } }
    # Should be prompted to create new user
    assert_redirected_to new_user_url(@pregame_room_code)
    follow_redirect!
    assert_template 'users/new'
    # Attempt to create user with duplicate name, it should fail
    assert_no_difference 'User.count' do
      post users_path(@pregame_room_code),
           params: { user: { name: @host_user.name } }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
    # Create new User in room
    assert_difference 'User.count', 1 do
      post users_path(@pregame_room_code),
           params: { user: { name: "Michael" } }
    end
    assert is_authenticated?
    # Should be redirected to waiting room
    assert_redirected_to room_url(@pregame_room_code)
    follow_redirect!
    assert_template 'rooms/show'
    # Ensure page displays the room code
    room = assigns(:room)
    assert_select "p", "#{room.code}"
    # Try to get into room again, should succeed
    post join_path,
         params: { room: { code: @pregame_room_code } }
    assert_template 'rooms/show'
  end
end

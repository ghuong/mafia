class PublishController < ApplicationController
  include PublishHelper

  before_action :has_joined_room
  before_action :is_host_of_room, only: [
    :announce_user_kicked, 
    :announce_roles_updated, 
    :announce_game_started, 
    :announce_room_destroyed
  ]

  # Announce to all users in room that a new user has joined
  def announce_user_joining
    @channel = PRIVATE_PUB_CHANNELS[:users_list] + "/#{@room.code}"
  end

  # Announce to all users in room that this user left
  def announce_user_leaving
    @channel = PRIVATE_PUB_CHANNELS[:users_list] + "/#{@room.code}"
  end

  # Announce to all users in room that the roles list has been updated
  def announce_roles_updated
    @channel = PRIVATE_PUB_CHANNELS[:roles_list] + "/#{@room.code}"
    @roles = @room.get_roles
    @roles_list_channel = PRIVATE_PUB_CHANNELS[:roles_list] + "/#{@room.code}"
  end

  # Announce to guests that game has started
  def announce_game_started
    @channel = PRIVATE_PUB_CHANNELS[:game_started] + "/#{@room.code}"
  end

  # Announce to all users in room that day phase has changed
  def announce_day_phase_changed
    @channel = PRIVATE_PUB_CHANNELS[:day_phase_changed] + "/#{@room.code}"
  end

  # Kick user from room and announce to all
  def announce_user_kicked
    @channel = PRIVATE_PUB_CHANNELS[:users_list] + "/#{@room.code}"
    user_kicked = @room.users.find_by(id: params[:user_id])
    @user_kicked_id = user_kicked.id
    user_kicked.destroy
  end

  def announce_vote_changed
    @channel = vote_channel(params[:room_code], params[:action_name], params[:user_id])
    @action_name = params[:action_name]
    @action_id = params[:action_id]
    @user_id = params[:user_id]
    @new_vote = Role::resolve_target(User.find_by(id: @user_id).get_action_target(@action_id.to_i)).name
  end

  def announce_ready
    @user_id = params[:user_id]
    @channel = PRIVATE_PUB_CHANNELS[:ready] + "/#{@room.code}/#{@user_id}"
    @is_ready = false
    user = User.find_by(id: @user_id)
    if user
      @is_ready = user.is_ready
    end
  end

  # Force everyone to leave the room
  def announce_room_destroyed
    @channel = PRIVATE_PUB_CHANNELS[:room_destroyed] + "/#{params[:room_code]}"
  end

  private

    # Ignore unauthorized requests
    def has_joined_room
      @user = current_user
      @room = Room.find_by(code: params[:room_code])
      if !@room || !has_already_joined?(@room, @user)
        render nothing: true
      end
    end

    # Ignore non-host requests
    def is_host_of_room
      if !is_host?(@room)
        render nothing: true
      end
    end
end
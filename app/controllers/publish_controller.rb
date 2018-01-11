class PublishController < ApplicationController
  before_action :has_joined_room
  before_action :is_host_of_room, only: [:announce_user_kicked, :announce_roles_updated, :announce_game_started]

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
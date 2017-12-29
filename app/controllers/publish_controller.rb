class PublishController < ApplicationController
  before_action :has_joined_room

  # Announce to all users in room that a new user has joined
  def announce_user_joining
    @channel = PRIVATE_PUB_CHANNELS[:users_list]
  end

  # Announce to all users in room that this user left
  def announce_user_leaving
    @channel = PRIVATE_PUB_CHANNELS[:users_list]
  end

  # Announce to all users in room that the roles list has been updated
  def announce_roles_updated
    @channel = PRIVATE_PUB_CHANNELS[:roles_list]
    @roles = @room.get_roles
  end

  # Announce to guests that game has started
  def announce_game_started
    @channel = PRIVATE_PUB_CHANNELS[:game_started]
  end

  # Announce to all users in room that day phase has changed
  def announce_day_phase_changed
    @channel = PRIVATE_PUB_CHANNELS[:day_phase_changed]
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
end
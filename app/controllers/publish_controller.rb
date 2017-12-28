class PublishController < ApplicationController
  before_action :has_joined_room

  # Announce to all users in room that a new user has joined
  def announce_user_joining
    @channel = PRIVATE_PUB_CHANNELS[:users_list]
  end

  def announce_user_leaving
    @channel = PRIVATE_PUB_CHANNELS[:users_list]
  end

  def announce_roles_updated
    @channel = PRIVATE_PUB_CHANNELS[:roles_list]
    @roles = @room.get_roles
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
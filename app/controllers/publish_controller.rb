class PublishController < ApplicationController
  def push_room_users
    @channel = PRIVATE_PUB_CHANNELS[:users_list]
    @user = current_user
    if @user.nil?
      render nothing: true and return
    end
  end
end
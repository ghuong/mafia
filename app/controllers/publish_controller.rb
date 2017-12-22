class PublishController < ApplicationController
  def announce_user_joining
    @channel = PRIVATE_PUB_CHANNELS[:users_list]
    @user = current_user
    if @user.nil?
      render nothing: true and return
    end
  end
end
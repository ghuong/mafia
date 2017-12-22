class PublishController < ApplicationController
  def announce_user_joining
    @channel = PRIVATE_PUB_CHANNELS[:users_list]
    @user = current_user
    if (@user.nil? || !current_user?(@user))
      render nothing: true and return
    end
  end

  def announce_user_leaving
    @channel = PRIVATE_PUB_CHANNELS[:users_list]
    @user = current_user
    if (@user.nil? || !current_user?(@user))
      render nothing: true and return
    end
  end
end
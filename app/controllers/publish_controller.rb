class PublishController < ApplicationController
  def push_room_users
    @path = "/blah"
    @user = current_user
    if @user.nil?
      render nothing: true and return
    end
  end
end
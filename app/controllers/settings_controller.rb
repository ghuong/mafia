class SettingsController < ApplicationController
  def edit
    @room = Room.find_by(code: params[:room_code])
    if @room && @room.is_pregame? && is_host?(@room)
      @users_list_channel = PRIVATE_PUB_CHANNELS[:users_list]
      @roles_list_channel = PRIVATE_PUB_CHANNELS[:roles_list]
      @users = @room.users
      @roles = @room.get_roles
      @role_options = MAFIA_ROLES
    else
      flash.now[:danger] = "That page is unavailable."
      render 'static_pages/home'
    end
  end

  def add_role
  end
end
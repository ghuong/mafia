class SettingsController < ApplicationController
  before_action :is_host_of_room

  def edit
    @users_list_channel = PRIVATE_PUB_CHANNELS[:users_list]
    @roles_list_channel = PRIVATE_PUB_CHANNELS[:roles_list]
    @users = @room.users
    @roles = @room.get_roles
    @role_options = MAFIA_ROLES
  end

  def add_role
    @role = params[:role]
    @room.add_role(@role)
    if @room.save
      redirect_to edit_settings_path(params[:room_code])
    else
      flash.now[:danger] = "Failed to add role"
      render :edit
    end
  end

  private

    # Redirect to home page if user is not authorized
    def is_host_of_room
      @room = Room.find_by(code: params[:room_code])
      if !@room || !@room.is_pregame? || !is_host?(@room)
        flash.now[:danger] = "That page is unavailable."
        render 'static_pages/home'
      end
    end
end
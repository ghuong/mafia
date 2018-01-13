class SettingsController < ApplicationController
  before_action :is_host_of_room

  def edit
    @users_list_channel = PRIVATE_PUB_CHANNELS[:users_list] + "/#{@room.code}"
    @roles_list_channel = PRIVATE_PUB_CHANNELS[:roles_list] + "/#{@room.code}"
    @users = @room.users
    @roles = @room.get_roles
    @role_options = MAFIA_ROLES.each_with_index.map do |role, idx|
      { id: idx, name: role[:name] }
    end
  end

  def add_role
    role = params[:role].to_i
    @room.add_role(role)
    if @room.save
      redirect_to edit_settings_path(params[:room_code])
    else
      flash.now[:danger] = "Failed to add role"
      render :edit
    end
  end

  def increment_role
    role = params[:role_id].to_i
    @room.add_role(role)
    if @room.save
      redirect_to edit_settings_path(params[:room_code])
    else
      flash.now[:danger] = "Failed to add role"
      render :edit
    end
  end

  def remove_role
    role = params[:role_id].to_i
    @room.remove_role(role)
    if @room.save
      redirect_to edit_settings_path(params[:room_code])
    else
      flash.now[:danger] = "Failed to remove role"
      render :edit
    end
  end

  def start_game
    roles = @room.get_roles
    users = @room.users
    num_roles = roles.reduce(0){|sum, role| sum + role[:count] }
    
    if users.length == num_roles
      # Set game state to start
      if @room.start_game
        redirect_to edit_actions_path(params[:room_code])
      else
        flash[:danger] = "Game failed to start."
        redirect_to edit_settings_path(params[:room_code])
      end
    else
      flash[:danger] = "Number of players and roles must match."
      redirect_to edit_settings_path(params[:room_code])
    end
  end

  private

    # Redirect to home page if user is not authorized
    def is_host_of_room
      @room = Room.find_by(code: params[:room_code])
      @user = current_user
      if !@room || !@room.is_pregame? || !is_host?(@room)
        flash.now[:danger] = "That page is unavailable."
        redirect_to root_path
      end
    end
end
class RoomsController < ApplicationController
  before_action :not_in_room, only: [:new, :create]

  def new
    @room = Room.new
  end

  def create
    @room = Room.new
    if @room.save
      @user = User.new(name: params[:name], room_id: @room.id, is_host: true)
      if @user.save
        remember @user
        @users = @room.users
        redirect_to edit_settings_path(@room.code) and return
      end
    end

    @room.destroy unless @room.nil?
    flash.now[:danger] = "Something went wrong."
    render :new
  end

  def join
    create_session if Rails.env.test?
    redirect_to room_path(params[:room][:code])
  end

  def show
    params[:room_code].upcase!
    @room = Room.find_by(code: params[:room_code])

    if @room
      @users = @room.users
      @user = current_user

      if @room.is_pregame?
        @roles = @room.get_roles
        @users_list_channel = PRIVATE_PUB_CHANNELS[:users_list] + "/#{@room.code}"
        @roles_list_channel = PRIVATE_PUB_CHANNELS[:roles_list] + "/#{@room.code}"
        @game_started_channel = PRIVATE_PUB_CHANNELS[:game_started] + "/#{@room.code}"
        @room_destroyed_channel = PRIVATE_PUB_CHANNELS[:room_destroyed] + "/#{@room.code}"

        if is_host?(@room) # host accesses settings page for room
          redirect_to edit_settings_path(@room.code) and return
        elsif has_already_joined?(@room) # guest user gets waiting room
          render :show and return
        else # new people must create a new user
          redirect_to new_user_path(@room.code) and return
        end
        
      elsif has_already_joined?(@room)
        if @room.is_in_progress? # game already started
          redirect_to edit_actions_path(@room.code) and return
        elsif @room.is_finished? # render the game verdict
          redirect_to verdict_path(@room.code) and return
        end
      end
    end

    @room = Room.new
    @room.errors.add(:code, "cannot be joined.")
    render 'static_pages/home'
  end

  def destroy
    @room = Room.find_by(code: params[:room_code])
    @room.destroy unless @room.nil?
    redirect_to root_path
  end

  private

    # Re-establish session for user
    def create_session
      user = User.find_by(id: params[:user_id])
      if user && user.authenticated?(:remember, params[:remember_token])
        remember(user)
      end
    end

    def not_in_room
      if is_in_a_room?
        redirect_to room_path(current_user.room.code)
      end
    end
end

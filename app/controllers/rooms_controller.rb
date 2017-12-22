class RoomsController < ApplicationController

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

  def show
    create_session if Rails.env.test?

    params[:room_code] ||= params[:room][:code].upcase
    @room = Room.find_by(code: params[:room_code])

    if @room
      @users = @room.users
      if @room.is_pregame?
        @users_list_channel = PRIVATE_PUB_CHANNELS[:users_list]
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
          render_verdict and return
        end
      end
    end

    @room = Room.new
    @room.errors.add(:code, "cannot be joined.")
    render 'static_pages/home'
  end

  private

    # Re-establish session for user
    def create_session
      user = User.find_by(id: params[:user_id])
      if user && user.authenticated?(:remember, params[:remember_token])
        remember(user)
      end
    end

    def render_verdict
      render :verdict
    end
end

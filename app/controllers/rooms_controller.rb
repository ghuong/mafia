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
        redirect_to edit_settings_path(@room.code) and return
      end
    end

    @room.destroy unless @room.nil?
    flash.now[:danger] = "Something went wrong."
    render :new
  end

  def show
    room_code = params[:room_code] || params[:room][:code]
    @room = Room.find_by(code: room_code)
    if !@room
      @room = Room.new
      @room.errors.add(:code, "does not exist.")
      render 'static_pages/home'
    # elsif @room.is_in_progress
    #   redirect_to edit_actions_path
    # elsif @room.is_finished
    #   redirect_to verdict_path
    elsif is_host?(@room)
      redirect_to edit_settings_path(@room.code)
    elsif has_already_joined?(@room)
      render :show
    else
      redirect_to new_user_path(@room.code)
    end
  end
end

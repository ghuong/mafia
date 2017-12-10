class RoomsController < ApplicationController
  
  def new
    @room = Room.new
  end

  def create
    @room = Room.new
    if @room.save
      @user = User.new(name: params[:name], room_id: @room.id)
      if @user.save
        redirect_to edit_settings_path(@room.code)
      else
        @room.destroy
        flash[:danger] = "Something went wrong."
        redirect_to root_path
      end
    else
      flash[:danger] = "Something went wrong."
      render :new
    end
  end

  def show
  end
end

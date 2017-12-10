class RoomsController < ApplicationController
  def new
  end

  def create
    @room = Room.new
    if @room.save
      redirect_to edit_settings_path(@room.code)
    else
      flash[:danger] = "Something went wrong."
      render :new
    end
  end

  def show
  end

  private

    def room_params

    end
end

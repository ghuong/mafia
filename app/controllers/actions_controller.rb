class ActionsController < ApplicationController
  def edit
    @room = Room.find_by(code: params[:room_code])

    if @room && @room.is_in_progress && has_already_joined?(@room)
      render :edit
    else
      flash.now[:danger] = "That page is unavailable."
      render 'static_pages/home'
    end
  end
end
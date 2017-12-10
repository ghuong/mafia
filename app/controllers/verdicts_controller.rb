class VerdictsController < ApplicationController
  def show
    @room = Room.find_by(code: params[:room_code])

    if @room && @room.is_finished && has_already_joined?(@room)
      render :show
    else
      flash.now[:danger] = "That page is unavailable."
      render 'static_pages/home'
    end
  end
end

class ActionsController < ApplicationController
  before_action :is_playing_in_room

  def edit
    @role = MAFIA_ROLES[current_user.role_id]
  end

  private

    # Redirect unauthorized users
    def is_playing_in_room
      @room = Room.find_by(code: params[:room_code])

      if !@room || !@room.is_in_progress? || !has_already_joined?(@room)
        flash.now[:danger] = "That page is unavailable."
        render 'static_pages/home'
      end
    end
end
class StaticPagesController < ApplicationController
  before_action :not_in_room, only: [:home]

  def home
    @room = Room.new
  end

  def help
  end

  private

    def not_in_room
      if is_in_a_room?
        redirect_to room_path(current_user.room.code)
      end
    end
end

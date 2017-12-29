class ActionsController < ApplicationController
  include ActionsHelper

  before_action :is_playing_in_room

  def edit
    @role = MAFIA_ROLES[@user.role_id]
    @actions = get_actions(@user.role_id, @room.day_phase, @room.users)
    @is_ready = @user.is_ready
  end

  def update
    is_currently_ready = @user.is_ready
    @user.is_ready = params[:is_ready]
    if @user.save
      render json: { is_ready: @user.is_ready }
    else
      render json: { is_ready: is_currently_ready }
    end
  end

  private

    # Redirect unauthorized users
    def is_playing_in_room
      @room = Room.find_by(code: params[:room_code])
      @user = current_user

      if !@room || !@room.is_in_progress? || !has_already_joined?(@room, @user)
        flash.now[:danger] = "That page is unavailable."
        render 'static_pages/home'
      end
    end
end
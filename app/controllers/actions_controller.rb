class ActionsController < ApplicationController
  include ActionsHelper

  before_action :is_playing_in_room

  def edit
    @role = MAFIA_ROLES[@user.role_id]
    @action_options = get_action_options(@user.id, @user.role_id, @room.day_phase, @room.users)
    @is_ready = @user.is_ready
    @day_phase_changed_channel = PRIVATE_PUB_CHANNELS[:day_phase_changed]
  end

  def update
    is_currently_ready = @user.is_ready
    @user.is_ready = params[:is_ready]
    if params[:player_action]
      @user.set_action_targets(player_action_params.to_hash.sort.to_h.values)
    end

    if @user.save
      all_ready = @room.users.all? { |user| user.is_ready }
      if all_ready
        @room.next_day_phase
      end
      render json: { is_ready: @user.is_ready, all_ready: all_ready }
    else
      render json: { is_ready: is_currently_ready, all_ready: false }
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

    # Returns the safe parameters
    def player_action_params
      params.require(:player_action).permit!
    end
end
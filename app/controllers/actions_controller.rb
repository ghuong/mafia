class ActionsController < ApplicationController
  include ActionsHelper

  before_action :is_playing_in_room, except: [:verdict]
  before_action :is_game_finished, only: [:verdict]
  before_action :is_alive, except: [:death, :verdict]
  before_action :is_dead, only: [:death]

  def edit
    @role = MAFIA_ROLES[@user.role_id]
    @action_options = get_action_options(@user.id, @user.role_id, @room.day_phase, @room.users)
    @is_ready = @user.is_ready
    @day_phase_changed_channel = PRIVATE_PUB_CHANNELS[:day_phase_changed] + "/#{@room.code}"
    @alive_users = @room.users.select { |user| user.is_alive }
    @dead_users = @room.users.select { |user| !user.is_alive }
    @roles = @room.get_roles
    @teammates = @room.users.select do |u|
      u.role[:team] == @user.role[:team] && @user.role[:team] != MAFIA_TEAMS[:solo] && u != @user
    end
    @reveal_teammates = !@user.is_villager?
    @reports = @user.get_reports
    @help_messages = get_help_messages
  end

  def update
    is_currently_ready = @user.is_ready
    @user.is_ready = params[:is_ready]
    if params[:player_action]
      @user.set_action_targets(player_action_params.to_hash.sort.to_h.values)
    end

    if @user.save
      all_ready = @room.all_ready?
      if all_ready
        @room.next_day_phase
      end
      
      render json: { 
        is_ready: @user.is_ready, 
        all_ready: all_ready
      }
    else
      render json: { 
        is_ready: is_currently_ready, 
        all_ready: false
      }
    end
  end

  # Show death page if user is dead
  def death
    @alive_users = @room.users.select { |user| user.is_alive }
    @dead_users = @room.users.select { |user| !user.is_alive }
    @roles = @room.get_roles
  end

  # Update a single action (without changing is_ready state)
  def update_single
    if params[:player_action]
      @user.set_action_target(player_action_params.keys.first.to_i, player_action_params.values.first)

      if @user.save
        action_id = params[:player_action].keys.first.to_i
        action_name = get_action_options(@user.id, @user.role_id, @room.day_phase, @room.users)[action_id][:name]

        render json: {
          action_name: action_name,
          action_id: action_id
        }
      end
    end
  end

  def verdict
    @reports = @user.get_reports
    @winners = @room.get_winners
    @winner_message = get_winner_message(@winners)
    @alive_users = @room.users.select { |user| user.is_alive }
    @dead_users = @room.users.select { |user| !user.is_alive }
    @winning_users = @room.users.select { |user| user.is_winner }
  end

  private

    # Redirect unauthorized users
    def is_playing_in_room
      @room = Room.find_by(code: params[:room_code])
      @user = current_user

      if @room && @room.is_finished?
        redirect_to verdict_path(params[:room_code]) and return
      end

      if !@room || !@room.is_in_progress? || !has_already_joined?(@room, @user)
        redirect_to root_path
      end
    end

    # Redirect if game not finished
    def is_game_finished
      @room = Room.find_by(code: params[:room_code])
      @user = current_user

      if @room && @room.is_in_progress?
        redirect_to edit_actions_path(params[:room_code]) and return
      end

      if !@room || !@room.is_finished? || !has_already_joined?(@room, @user)
        redirect_to root_path
      end
    end

    # If user is dead, redirect to death page
    def is_alive
      @user = current_user
      redirect_to death_path(params[:room_code]) unless @user.is_alive
    end

    # If user is alive, redirect to room show page
    def is_dead
      @user = current_user
      redirect_to room_path(params[:room_code]) unless !@user.is_alive
    end

    # Returns the safe parameters
    def player_action_params
      params.require(:player_action).permit!
    end

    # Get the Help messages to show users
    def get_help_messages
      help_messages = []
      if @room.day_phase_counter <= 2
        case @room.day_phase
        when "night"
          help_messages << [
            "It is the first Night.",
            "You cannot speak or look at others during Night.",
            "Keep your phone screen hidden from others."
          ]
          help_messages << [
            "Click 'Role' above to see your role.",
            "Choose a target if you have special abilities.",
            "Press 'Submit'. Once everyone is 'Ready', day will begin."
          ]
        when "day"
          help_messages << [
            "It is the first Day.",
            "Living players may talk openly, but dead players must be silent.",
            "Keep your phone screen hidden from others."
          ]
          help_messages << [
            "Vote on who you wish to get lynched.",
            "A player is lynched only if they receive more than half the votes.",
            "Press 'Submit'. Once everyone is 'Ready', night will begin."
          ]
        end
      else
        case @room.day_phase
        when "day"
          help_messages << ["Remember, you need more than half the votes to lynch someone."]
        end
      end
      return help_messages
    end

    def get_winner_message(winners)
      case winners.length
      when 0
        return "Nobody wins!"
      when 1
        winner_text = winners[0]
      else
        winner_text = winners[0..-2].join(", ") + ", and #{winners[-1]}"
      end

      return "The #{winner_text} wins!"
    end
end
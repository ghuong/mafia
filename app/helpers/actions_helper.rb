module ActionsHelper

  TARGET_NOBODY = -1.freeze
  TARGET_UNDECIDED = -2.freeze

  # Get array of actions for the given role_id
  def get_action_options(user_id, role_id, day_phase, all_users)
    actions = []
    role = MAFIA_ROLES[role_id][:name]
    living_users = all_users.select { |user| user.is_alive }

    if day_phase == "night"
      case role
      when "Mafia"
        actions.push(*get_mafia_actions(living_users))
      end

    elsif day_phase == "day"
      actions.push(*get_day_actions(living_users))
    end

    user = User.find_by(id: user_id)
    selected_targets = user.get_action_targets
    actions.each_with_index do |action, idx|
      action[:id] = idx

      if !selected_targets.empty?
        action[:selected] = selected_targets[idx]
      end

      # Show other votes for certain actions
      add_other_votes(living_users, action, idx, user_id)
    end

    return actions
  end

  def vote_channel(room_code, action_name, user_id)
    PRIVATE_PUB_CHANNELS[:other_votes] + "/#{room_code}/#{action_name}/#{user_id}"
  end

  def ready_channel(room_code, user_id)
    PRIVATE_PUB_CHANNELS[:ready] + "/#{room_code}/#{user_id}"
  end

  def resolve_target(target_id)
    case target_id
    when TARGET_NOBODY
      User.new(id: target_id, name: "Nobody")
    when TARGET_UNDECIDED
      User.new(id: target_id, name: "Undecided")
    else
      User.find_by(id: target_id)
    end
  end

  private

    # Returns a list of mafia actions
    def get_mafia_actions(living_users)
      targets = living_users.select do |user|
        !user.is_mafia?
      end.map do |user|
        format_target(user)
      end

      targets = [
        { user_id: TARGET_UNDECIDED, name: "" },
        { user_id: TARGET_NOBODY, name: "Nobody" }
      ] + targets

      [format_action(ACTIONS[:kill][:name], ACTIONS[:kill][:description], targets)]
    end

    # Returns a list of the day actions
    def get_day_actions(living_users)
      targets = living_users.map { |user| format_target(user) }

      targets = [
        { user_id: TARGET_UNDECIDED, name: "" },
        { user_id: TARGET_NOBODY, name: "Nobody" }
      ] + targets

      [format_action(ACTIONS[:lynch][:name], ACTIONS[:lynch][:description], targets)]
    end

    # Returns a hash representing an action for a role
    def format_action(action_name, action_description, targets)
      { name: action_name, description: action_description, targets: targets }
    end

    # Returns a hash representing a target for an action
    def format_target(user)
      { user_id: user.id, name: user.name }
    end

    # Returns a hash representing another player's vote of the same action
    def format_other_vote(user, vote)
      { user_id: user.id, user_name: user.name, vote: vote, is_ready: user.is_ready }
    end

    # Adds the other users' votes to this action
    def add_other_votes(living_users, action, action_idx, current_user_id)
      user_select_proc = Proc.new do |user|
        if user.id == current_user_id
          false
        else 
          case action[:name]
          when ACTIONS[:kill][:name]
            user.is_mafia?
          when ACTIONS[:lynch][:name]
            true
          else
            false
          end
        end
      end

      action[:other_votes] = living_users.select(&user_select_proc).map do |user|
        vote = resolve_target(user.get_action_target(action_idx)).name
        format_other_vote(user, vote)
      end
    end
end
module ActionsHelper

  # Get array of actions for the given role_id
  def get_action_options(user_id, role_id, day_phase, all_users)
    actions = []
    role = MAFIA_ROLES[role_id]
    living_users = all_users.select { |user| user.is_alive }

    if day_phase == "night"
      case role
      when "Mafia"
        actions.push(*get_mafia_actions(living_users))
      end

    elsif day_phase == "day"

    end

    actions.each_with_index { |action, idx| action[:id] = idx }
    return actions
  end

  private

    # Returns a list of mafia actions
    def get_mafia_actions(living_users)
      targets = living_users.select do |user|
        !user.is_mafia?
      end.map do |user|
        format_target(user)
      end

      [format_action(ACTIONS[:kill][:name], ACTIONS[:kill][:description], targets)]
    end

    # Returns a hash representing an action for a role
    def format_action(action_name, action_description, targets)
      { name: action_name, description: action_description, targets: targets }
    end

    # Returns a hash representing a target for an action
    def format_target(user)
      { user_id: user.id, name: user.name }
    end
end
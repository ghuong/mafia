module ActionsHelper
  # Get array of actions for the given role_id
  def get_action_options(user_id, role_id, day_phase, users)
    actions = []
    role = MAFIA_ROLES[role_id].downcase

    if day_phase == "night"
      case role
      when "mafia"
        actions.push(*get_mafia_actions(users))
      end

    elsif day_phase == "day"

    end

    actions.each_with_index { |action, idx| action[:id] = idx }
    return actions
  end

  private

    # Returns a list of mafia actions
    def get_mafia_actions(users)
      non_targets = ['mafia']
      targets = users.select do |user|
        !(non_targets.include? MAFIA_ROLES[user.role_id].downcase)
      end.map do |user|
        format_target(user)
      end

      [format_action("kill", "Kill", targets)]
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
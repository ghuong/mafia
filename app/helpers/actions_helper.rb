module ActionsHelper
  # Get array of actions for the given role_id
  def get_actions(role_id, day_phase, users)
    actions = []
    role = MAFIA_ROLES[role_id].downcase

    if day_phase == "night"
      case role
      when "mafia"
        actions.push(*get_mafia_actions(users))
      end

    elsif day_phase == "day"

    end

    return actions
  end

  private

    def get_mafia_actions(users)
      non_targets = ['mafia']
      targets = users.select do |user|
        !(non_targets.include? MAFIA_ROLES[user.role_id].downcase)
      end.map do |user|
        { user_id: user.id, name: user.name }
      end

      [{ name: "kill", description: "Kill", targets: targets }]
    end
end
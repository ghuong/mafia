class MafiaRole < Role

  def team
    MAFIA_TEAMS[:mafia]
  end

  def objective
    MAFIA_OBJECTIVES[:mafia]
  end

  def ability
    "At night, each Mafia votes for a victim. Of the victims with the most votes, one will be killed at random."
  end

  protected 

    def get_night_actions
      targets = @living_users.select do |u|
        !u.is_mafia?
      end.map do |u|
        format_target(u)
      end

      targets.unshift(get_nobody_target)
      targets.unshift(get_undecided_target)

      [format_action(ACTIONS[:kill][:name], ACTIONS[:kill][:description], targets)]
    end

    def add_other_votes(action, action_idx)
      other_users = case action[:name]
      when ACTIONS[:kill][:name]
        @living_users.select { |u| u.is_mafia? && u != @user }
      else
        []
      end

      super(action, action_idx, other_users)
    end
end
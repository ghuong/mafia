class Doctor < Role
  
  def team
    MAFIA_TEAMS[:village]
  end

  def objective
    MAFIA_OBJECTIVES[:village]
  end

  def ability
    "At night, you heal another player. That player will not die that night."
  end

  protected

    def get_night_actions
      targets = @living_users.select { |u| u.id != @user.id }.map do |u|
        format_target(u)
      end

      targets.unshift(get_nobody_target)
      targets.unshift(get_undecided_target)

      [format_action(ACTIONS[:heal][:name], ACTIONS[:heal][:description], targets)]
    end
end
class Cop < Role

  def team
    MAFIA_TEAMS[:village]
  end

  def objective
    MAFIA_OBJECTIVES[:village]
  end

  def ability
    "At night, you investigate another player. In the morning, you learn whether or not they are Mafia."
  end

  protected

    def get_night_actions
      targets = @living_users.select { |u| u.id != @user.id }.map do |u|
        format_target(u)
      end

      targets.unshift(get_nobody_target)
      targets.unshift(get_undecided_target)

      [format_action(ACTIONS[:investigate][:name], ACTIONS[:investigate][:description], targets)]
    end

    def process_night_actions(killed_users)
      target_id = @user.get_target(ACTIONS[:investigate][:name])
      target = @living_users.find { |user| user.id == target_id }
      if target
        if target.is_mafia?
          @user.add_report("Cop Report: #{target.name} is a Mafia!")
        else
          @user.add_report("Cop Report: #{target.name} is innocent!")
        end
      end
    end
end
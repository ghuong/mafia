module RoomsHelper
  include ActionsHelper

  # Process all of the user's actions
  def process_user_actions(day_phase, all_users)
    living_users = all_users.select { |user| user.is_alive }
    killed_users = []
    lynched_users = []
    
    if day_phase == 'night'
      victim = process_mafia_kill(living_users)
      if victim
        killed_users << victim
      end

      living_users.each do |user|
        case MAFIA_ROLES[user.role_id][:name]
        when "Cop"
          process_cop_investigation(user, living_users)
        end
      end
    elsif day_phase == 'day'
      victim = process_lynch(living_users)
      if victim
        lynched_users << victim
      end
    end

    # Write Reports for the transpired events
    all_users.each do |user|
      killed_users.each do |killed_user|
        user.add_report("#{killed_user.name} was killed!")
      end

      lynched_users.each do |lynched_user|
        user.add_report("#{lynched_user.name} was lynched!")
      end
    end
  end

  # Process if the game is over
  def process_game_over(room, all_users)
    living_users = all_users.select { |user| user.is_alive }
    winners = []
    if do_villagers_win?(living_users)
      winners << "Village"
      all_users.select { |user| user.is_villager? }.each do |user|
        user.is_winner = true
      end
    elsif do_mafia_win?(living_users)
      winners << "Mafia"
      all_users.select { |user| user.is_mafia? }.each do |user|
        user.is_winner = true
      end
    else
      return
    end

    room.state = 'finished'
    room.winners = winners.join(",")
  end

  private

    # Process mafia kill
    def process_mafia_kill(living_users)
      living_mafia = living_users.select { |user| user.is_mafia? }
      mafia_kill_votes = living_mafia.map do |mafia|
        mafia.get_target(ACTIONS[:kill][:name])
      end
      majority_vote = mode(mafia_kill_votes).first.shuffle.first
      victim = living_users.find { |user| user.id == majority_vote }
      if victim
        victim.kill
        return victim
      end
    end

    # Process lynch vote
    def process_lynch(living_users)
      lynch_votes = living_users.map do |user|
        user.get_target(ACTIONS[:lynch][:name])
      end
      majority_vote, freq = mode(lynch_votes)
      majority_vote = majority_vote.first
      if freq > living_users.length / 2
        victim = living_users.find { |user| user.id == majority_vote }
        if victim
          victim.kill
          return victim
        end
      end
    end

    # Process cop investigation
    def process_cop_investigation(cop, living_users)
      target_id = cop.get_target(ACTIONS[:investigate][:name])
      target = living_users.find { |user| user.id == target_id }
      if target
        if target.is_mafia?
          cop.add_report("Cop Report: #{target.name} is a Mafia!")
        else
          cop.add_report("Cop Report: #{target.name} is innocent!")
        end
      end
    end

    # Returns an array of the mode values, and the frequency of each
    def mode(arr)
      freq = arr.inject(Hash.new(0)) { |h, v| h[v] += 1; h }
      max = freq.values.max
      return freq.select { |k, f| f == max }.keys, max
    end

    # Returns true iff all Mafia are dead, and at least one villager is alive
    def do_villagers_win?(living_users)
      living_users.none? { |user| user.is_mafia? } && !living_users.empty?
    end

    # Returns true iff at least half of the living players are Mafia
    def do_mafia_win?(living_users)
      living_users.count { |user| user.is_mafia? } >= (living_users.length + 1) / 2
    end
end

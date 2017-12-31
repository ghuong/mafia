module RoomsHelper

  # Process all of the user's actions
  def process_user_actions(day_phase, all_users)
    living_users = all_users.select { |user| user.is_alive }
    
    if day_phase == 'night'
      process_mafia_kill(living_users)
    end
  end

  private

    # Process mafia kill
    def process_mafia_kill(living_users)
      living_mafia = living_users.select { |user| user.is_mafia? }
      mafia_kill_votes = living_mafia.map do |mafia|
        mafia.get_target(ACTIONS[:kill][:name]);
      end
      majority_vote = mode(mafia_kill_votes).shuffle.first
      victim = living_users.find { |user| user.id == majority_vote }
      if victim
        victim.kill
      end
    end

    def mode(arr)
      freq = arr.inject(Hash.new(0)) { |h, v| h[v] += 1; h }
      max = freq.values.max
      freq.select { |k, f| f == max }.keys
    end
end

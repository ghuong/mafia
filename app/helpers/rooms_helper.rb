module RoomsHelper
  include ActionsHelper

  # Process all of the user's actions
  def process_user_actions(day_phase, all_users)
    living_users = all_users.select { |user| user.is_alive }
    
    if day_phase == 'night'
      process_mafia_kill(living_users)
    elsif day_phase == 'day'
      process_lynch(living_users)
    end
  end

  # Process if the game is over
  def process_game_over(room, all_users)
    living_users = all_users.select { |user| user.is_alive }
    winners = []
    if do_villagers_win?(living_users)
      winners << "Villagers"
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
        mafia.get_target(ACTIONS[:kill][:name]);
      end
      majority_vote = mode(mafia_kill_votes).first.shuffle.first
      victim = living_users.find { |user| user.id == majority_vote }
      if victim
        victim.kill
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

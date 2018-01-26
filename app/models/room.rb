class Room < ApplicationRecord
  has_many :users, dependent: :destroy

  before_create :generate_room_code

  ROOM_CODE_LENGTH = 4

  # Return true iff game is in "pregame" state
  def is_pregame?
    state == 'pregame'
  end

  # Return true iff game is in "playing" state
  def is_in_progress?
    state == 'playing'
  end

  # Return true iff game is in "finished" state
  def is_finished?
    state == 'finished'
  end

  # Returns a list of roles
  def get_roles
    result = roles.split(",").each_with_index.map do |count, idx|
      { 
        role: Role.get_role(idx),
        count: count.to_i
      }
    end

    if result.length < Role::MAFIA_ROLES.length
      Role::MAFIA_ROLES.length.times.map do |idx|
        { 
          role: Role.get_role(idx),
          count: 0
        }
      end
    else
      result
    end
  end

  # Add role to the room's setup
  def add_role(id)
    if Role::is_role_id(id)
      roles = get_roles
      roles[id][:count] += 1
      set_roles(roles)
    end
  end

  # Remove role from the room's setup
  def remove_role(id)
    if Role::is_role_id(id)
      roles = get_roles
      roles[id][:count] -= roles[id][:count] > 0 ? 1 : 0
      set_roles(roles)
    end
  end

  # Starts the game
  def start_game
    self.state = 'playing'
    self.day_phase = 'night'

    roles = get_roles

    role_deck = []
    roles.each do |role|
      role[:count].times { role_deck << role[:role].id }
    end
    role_deck.shuffle!

    # Assign role to each user
    self.users.each_with_index do |user, idx|
      user.role_id = role_deck[idx]
    end

    # Save users to DB
    Room.transaction do
      self.save
      User.transaction do
        self.users.each(&:save)
      end
    end
  end

  # Returns true iff all living users are ready
  def all_ready?
    self.users.all? { |user| user.is_ready || !user.is_alive }
  end

  # Progress to next day phase
  def next_day_phase
    clear_reports

    # Process all user actions
    process_user_actions
    
    # Determine if the game is over
    process_game_over

    # Progress to next day phase
    self.day_phase = self.day_phase == 'night' ? 'day' : 'night'
    self.day_phase_counter += 1
    # Clear all user actions
    self.users.each do |user|
      user.is_ready = false
      user.actions = ''
    end

    # Save users to DB
    Room.transaction do
      self.save
      User.transaction do
        self.users.each(&:save)
      end
    end
  end

  def get_winners
    self.winners.split(",")
  end

  private

    # Generate unique room code
    def generate_room_code
      self.code = loop do
        random_code = get_random_code(ROOM_CODE_LENGTH)
        break random_code unless Room.exists?(code: random_code)
      end
    end

    # Returns a random string of capitalized letters
    def get_random_code(length)
      o = [('A'..'Z')].map(&:to_a).flatten
      (0...length).map { o[rand(o.length)] }.join
    end

    # Set the roles field
    def set_roles(roles)
      self.roles = roles.map { |role| role[:count].to_s }.join(",")
    end

    # Clear all Reports for users
    def clear_reports
      self.users.each { |user| user.clear_reports }
    end

    # Process all of the user's actions
    def process_user_actions
      living_users = self.users.select { |u| u.is_alive }
      killed_users = []
      lynched_users = []
      immune_users = []
      
      case self.day_phase 
      when 'night'
        immune_users = get_immune_users(living_users)
        process_mafia_kill(living_users, killed_users)
      when 'day'
        process_lynch(living_users, lynched_users)
      end

      living_users.each { |user| user.role.process_independent_actions(killed_users) }

      # Kill the users that aren't immune
      killed_users.each { |user| user.kill unless immune_users.include? user.id }
      lynched_users.each { |user| user.kill }

      # Write Reports for the transpired events
      self.users.each do |user|
        killed_users.each do |killed_user|
          user.add_report("#{killed_user.name} was killed!") unless immune_users.include? killed_user.id
        end

        lynched_users.each do |lynched_user|
          user.add_report("#{lynched_user.name} was lynched!")
        end
      end
    end

    # Process if the game is over
    def process_game_over
      living_users = self.users.select { |user| user.is_alive }
      winners = []
      if do_villagers_win?(living_users)
        winners << "Village"
        self.users.select { |user| user.is_villager? }.each do |user|
          user.is_winner = true
        end
      elsif do_mafia_win?(living_users)
        winners << "Mafia"
        self.users.select { |user| user.is_mafia? }.each do |user|
          user.is_winner = true
        end
      else
        return
      end

      self.state = 'finished'
      self.winners = winners.join(",")
    end

    # Return a list of which users are immune to being killed
    def get_immune_users(living_users)
      doctors = living_users.select { |user| user.role.name == "Doctor" }
      return doctors.map do |doctor|
        doctor.get_target(Role::ACTIONS[:heal][:name])
      end
    end

    # Process mafia kill
    def process_mafia_kill(living_users, killed_users)
      living_mafia = living_users.select { |user| user.is_mafia? }
      mafia_kill_votes = living_mafia.map do |mafia|
        mafia.get_target(Role::ACTIONS[:kill][:name])
      end
      majority_vote = mode(mafia_kill_votes).first.shuffle.first
      victim = living_users.find { |user| user.id == majority_vote }
      if victim
        killed_users << victim
      end
    end

    # Process lynch vote
    def process_lynch(living_users, lynched_users)
      lynch_votes = living_users.map do |user|
        user.get_target(Role::ACTIONS[:lynch][:name])
      end
      majority_vote, freq = mode(lynch_votes)
      majority_vote = majority_vote.first
      if freq > living_users.length / 2
        victim = living_users.find { |user| user.id == majority_vote }
        if victim
          lynched_users << victim
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

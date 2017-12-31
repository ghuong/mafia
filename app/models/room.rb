class Room < ApplicationRecord
  include RoomsHelper

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
      { id: idx, name: MAFIA_ROLES[idx], count: count.to_i }
    end

    if result.length < MAFIA_ROLES.length
      MAFIA_ROLES.each_with_index.map do |role, idx|
        { id: idx, name: role, count: 0 }
      end
    else
      result
    end
  end

  # Add role to the room's setup
  def add_role(id)
    if id < MAFIA_ROLES.length
      roles = get_roles
      roles[id][:count] += 1
      set_roles(roles)
    end
  end

  # Remove role from the room's setup
  def remove_role(id)
    if id < MAFIA_ROLES.length
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
      role[:count].times { role_deck << role[:id] }
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

  def all_ready?
    self.users.all? { |user| user.is_ready || !user.is_alive }
  end

  # Progress to next day phase
  def next_day_phase
    # Process all user actions
    process_user_actions(self.day_phase, self.users)
    
    # Progress to next day phase
    self.day_phase = self.day_phase == 'night' ? 'day' : 'night'
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
end

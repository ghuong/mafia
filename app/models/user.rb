class User < ApplicationRecord
  include ActionsHelper

  belongs_to :room

  attr_accessor :remember_token

  before_create :create_remember_digest, :remove_trailing_spaces_in_name

  validates :name, presence: true, length: { maximum: 20 }
  validate :room_exists, on: :create
  validate :name_is_unique_in_room, on: :create
  validate :action_targets_are_valid

  # Returns true if the given token matches the digest
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Returns a random token
  def User.new_token
    SecureRandom.urlsafe_base64  
  end

  # Returns the hash digest of the given string
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a list of targets (user ids) for each of the user's actions
  def get_action_targets
    self.actions.split(",").map { |target| target.to_i }
  end

  # Set the targets (user ids)
  def set_action_targets(targets)
    self.actions = targets.join(",")
  end

  # Returns true iff user is on Mafia team
  def is_mafia?
    ['Mafia'].include? MAFIA_ROLES[role_id]
  end

  # Returns the user's target for a specific action
  def get_target(action_name)
    action_options = get_action_options(id, role_id, room.day_phase, room.users)
    action_index = action_options.find_index do |option|
      option[:name] == action_name
    end
    get_action_targets[action_index]
  end

  # Kill this user
  def kill
    self.is_alive = false
    self.save!
  end

  private

    # Generate a token, and store a hash digest of it in database to authenticate user in future
    def create_remember_digest
      self.remember_token = User.new_token
      self.remember_digest = User.digest(remember_token)
    end

    # Remove trailing spaces in the user's name
    def remove_trailing_spaces_in_name
      self.name.strip!
    end

    # Returns true iff the user belongs to an existing Room
    def room_exists
      if !Room.exists?(self.room_id)
        errors.add(:room_id, "does not exist")
      end
    end

    # Returns true iff user's name is unique to the Room
    def name_is_unique_in_room
      room = Room.find_by(id: room_id)
      if room && room.users.any? { |user| user.name.downcase == self.name.strip.downcase }
        errors.add(:name, "is already taken")
      end
    end

    # Returns true iff the targets of the user's action are valid
    def action_targets_are_valid
      return true if !is_ready || role_id.nil?

      valid_actions = get_action_options(id, role_id, room.day_phase, room.users)
      chosen_targets = get_action_targets
      is_valid = chosen_targets.length == valid_actions.length &&
        chosen_targets.each_with_index.all? do |chosen_target, idx|
          target_options = valid_actions[idx][:targets].map do |target_option|
            target_option[:user_id]
          end
          target_options.include? chosen_target
        end

      return is_valid
    end
end

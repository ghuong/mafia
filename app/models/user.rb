class User < ApplicationRecord
  belongs_to :room

  attr_accessor :remember_token

  before_create :create_remember_digest, :remove_trailing_spaces

  validates :name, presence: true, length: { maximum: 20 }
  validate :room_exists, on: :create
  validate :name_is_unique_in_room, on: :create

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

  private

    def create_remember_digest
      self.remember_token = User.new_token
      self.remember_digest = User.digest(remember_token)
    end

    def remove_trailing_spaces
      self.name.strip!
    end

    def room_exists
      if !Room.exists?(self.room_id)
        errors.add(:room_id, "does not exist")
      end
    end

    def name_is_unique_in_room
      room = Room.find_by(id: room_id)
      if room && room.users.any? { |user| user.name.downcase == self.name.strip.downcase }
        errors.add(:name, "is already taken")
      end
    end
end

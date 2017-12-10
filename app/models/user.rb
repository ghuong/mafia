class User < ApplicationRecord
  belongs_to :room

  attr_accessor :remember_token

  before_create :create_remember_digest

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
end

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
    roles.split(",")
  end

  # Add role to the room's setup
  # def add_role(role)

  # end

  # Remove role from the room's setup
  # def remove_role(role)

  # end

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
end

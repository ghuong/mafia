class Room < ApplicationRecord
  has_many :users, dependent: :destroy

  before_create :generate_room_code

  ROOM_CODE_LENGTH = 4

  def is_pregame?
    state == 'pregame'
  end

  def is_in_progress?
    state == 'playing'
  end

  def is_finished?
    state == 'finished'
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
end

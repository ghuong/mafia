class Room < ApplicationRecord
  has_many :users
  # belongs_to :user, foreign_key: :host_id, class_name: "User"

  before_create :generate_code

  private

    def generate_code
      self.code = "1234"
    end
end

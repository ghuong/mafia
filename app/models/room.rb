class Room < ApplicationRecord
  before_create :generate_code

  has_many :users
  # belongs_to :user, foreign_key: :host_id, class_name: "User"

  private

    def generate_code
      self.code = "1234"
    end
end

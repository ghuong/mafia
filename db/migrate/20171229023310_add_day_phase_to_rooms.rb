class AddDayPhaseToRooms < ActiveRecord::Migration[5.1]
  def change
    add_column :rooms, :day_phase, :string
  end
end

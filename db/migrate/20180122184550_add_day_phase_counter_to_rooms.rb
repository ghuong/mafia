class AddDayPhaseCounterToRooms < ActiveRecord::Migration[5.1]
  def change
    add_column :rooms, :day_phase_counter, :integer, default: 1
  end
end

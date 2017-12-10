class CreateRooms < ActiveRecord::Migration[5.1]
  def change
    create_table :rooms do |t|
      t.string :code, unique: true
      t.string :state, default: 'pregame'

      t.timestamps
    end
  end
end

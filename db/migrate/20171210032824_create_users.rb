class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.integer :room_id
      t.string :name
      t.string :authentication_digest

      t.timestamps
    end
  end
end

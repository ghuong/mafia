class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.integer :room_id
      t.string :name
      t.string :remember_digest
      t.boolean :is_host, default: false

      t.timestamps
    end
  end
end

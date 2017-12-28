class AddRolesToRooms < ActiveRecord::Migration[5.1]
  def change
    add_column :rooms, :roles, :string, default: ''
  end
end

class AddIsReadyAndIsAliveToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :is_ready, :boolean, default: false
    add_column :users, :is_alive, :boolean, default: true
  end
end

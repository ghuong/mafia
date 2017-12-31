class AddActionsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :actions, :string, default: ''
  end
end

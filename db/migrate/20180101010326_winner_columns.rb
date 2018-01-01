class WinnerColumns < ActiveRecord::Migration[5.1]
  def change
    add_column :rooms, :winners, :string, default: ''
    add_column :users, :is_winner, :boolean, default: false
  end
end

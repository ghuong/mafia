class AddReportsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :reports, :string, default: ''
  end
end

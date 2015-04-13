class AddConnectedToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :is_connected, :boolean, default: false
  end
end

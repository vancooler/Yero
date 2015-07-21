class AddTimezoneNameToUser < ActiveRecord::Migration
  def change
  	add_column :users, :timezone_name, :string
  end
end
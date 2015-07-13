class AddLevelToAdminUser < ActiveRecord::Migration
  def change
  	add_column :admin_users, :level, :integer
  end
end
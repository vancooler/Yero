class AddLastStatusActiveTimeToUser < ActiveRecord::Migration
  def change
  	add_column :users, :last_status_active_time, :datetime, :default => Time.now
  end
end
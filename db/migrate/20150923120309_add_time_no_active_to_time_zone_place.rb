class AddTimeNoActiveToTimeZonePlace < ActiveRecord::Migration
  def change
  	add_column :time_zone_places, :time_no_active, :integer
  end
end
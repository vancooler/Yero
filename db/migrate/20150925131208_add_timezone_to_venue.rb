class AddTimezoneToVenue < ActiveRecord::Migration
  def change
  	add_column :venues, :timezone, :string, :default => "America/Vancouver"
  	add_column :venues, :start_time, :datetime
  	add_column :venues, :end_time, :datetime
  end
end
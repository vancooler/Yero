class AddCenterOffsetToVenues < ActiveRecord::Migration
  def change
  	add_column :venues, :center_offset, :float
  end
end


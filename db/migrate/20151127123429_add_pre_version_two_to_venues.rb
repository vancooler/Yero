class AddPreVersionTwoToVenues < ActiveRecord::Migration
  def change
  	add_column :venues, :pre_version_two, :boolean, default: false
  end
end


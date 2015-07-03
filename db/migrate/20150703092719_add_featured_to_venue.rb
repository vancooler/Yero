class AddFeaturedToVenue < ActiveRecord::Migration
  def change
  	add_column :venues, :featured, :boolean, default: false
  	add_column :venues, :featured_order, :integer
  end
end

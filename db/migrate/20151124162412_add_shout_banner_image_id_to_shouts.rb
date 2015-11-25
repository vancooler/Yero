class AddShoutBannerImageIdToShouts < ActiveRecord::Migration
  def change
  	add_column :shouts, :shout_banner_image_id, :integer
  end
end


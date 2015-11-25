class CreateShoutBannerImages < ActiveRecord::Migration
  def change
    create_table :shout_banner_images do |t|
    	t.string :avatar
    	t.string :image_url
    	t.boolean :is_active
    	t.timestamps
    end

  end
end
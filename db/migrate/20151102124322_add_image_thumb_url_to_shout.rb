class AddImageThumbUrlToShout < ActiveRecord::Migration
  def change
  	add_column :shouts, :image_thumb_url, :text
  	add_column :shout_comments, :image_thumb_url, :text
  end
end


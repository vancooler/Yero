class AddImageUrlAndThumbUrlToAdminAction < ActiveRecord::Migration
  def change
    add_column :admin_actions, :image_url, :string
    add_column :admin_actions, :thumb_url, :string
  end
end


class ChangeLayerIdInUsers < ActiveRecord::Migration
  def change
    change_column :users, :layer_id, :text, :limit => nil
  end
end
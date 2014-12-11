class AddDiscoveryExclusiveToUser < ActiveRecord::Migration
  def change
  	add_column :users, :discovery, :boolean
  	add_column :users, :exclusive, :boolean
  end
end

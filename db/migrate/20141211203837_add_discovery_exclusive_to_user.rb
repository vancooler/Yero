class AddDiscoveryExclusiveToUser < ActiveRecord::Migration
  def change
  	add_column :users, :discovery, :boolean, default: true
  	add_column :users, :exclusive, :boolean, default: true
  end
end

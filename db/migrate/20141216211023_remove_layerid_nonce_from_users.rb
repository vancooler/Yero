class RemoveLayeridNonceFromUsers < ActiveRecord::Migration
  def change
  	remove_column :users, :layer_id
  	remove_column :users, :nonce
  end
end

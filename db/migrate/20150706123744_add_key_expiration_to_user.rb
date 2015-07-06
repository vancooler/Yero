class AddKeyExpirationToUser < ActiveRecord::Migration
  def change
  	add_column :users, :key_expiration, :datetime
  end
end
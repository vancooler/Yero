class AddNonceToUsers < ActiveRecord::Migration
  def change
    add_column :users, :nonce, :string
  end
end
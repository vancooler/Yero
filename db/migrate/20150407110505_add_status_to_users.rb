class AddStatusToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :account_status, :integer
  end
end

class AddDeviseToUsers < ActiveRecord::Migration
  def self.up
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    remove_column :users, :encrypted_password, :string  
    remove_column :users, :reset_password_token, :string
    remove_column :users, :reset_password_sent_at, :datetime
    remove_column :users, :sign_in_count, :integer
    remove_column :users, :current_sign_in_at, :datetime
    remove_column :users, :current_sign_in_ip, :string
    remove_column :users, :last_sign_in_ip, :string
    remove_column :users, :last_sign_in_at, :datetime
  end
end

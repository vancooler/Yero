class AddEmailResetTokenToUser < ActiveRecord::Migration
  def change
  	add_column :users, :email_reset_token, :string
  end
end
class AddEmailSnapchatWechatPasswordToUsers < ActiveRecord::Migration
  def change
  	remove_column :email
  	remove_column :snapchat_id
  	remove_column :wechat_id
  	add_column :users, :email, :string, unique: true, null: false
  	add_column :users, :snapchat_id, :string
  	add_column :users, :wechat_id, :string
  	add_column :users, :password, :string, null: false
  end
end

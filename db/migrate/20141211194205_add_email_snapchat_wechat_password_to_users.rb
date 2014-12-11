class AddEmailSnapchatWechatPasswordToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :email, :string, unique: true
  	add_column :users, :snapchat_id, :string
  	add_column :users, :wechat_id, :string
  	add_column :users, :password, :string
  end
end

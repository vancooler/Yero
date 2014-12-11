class AddEmailSnapchatWechatToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :email, :string
  	add_column :users, :snapchat_id, :string
  	add_column :users, :wechat_id, :string
  end
end

class RemoveEmailWechatSnapchatFromUsers < ActiveRecord::Migration
  def change
  	remove_column :users, :email
  	remove_column :users, :snapchat_id, :string
  	remove_column :users, :wechat_id, :string
  end
end

class AddUsernameToUser < ActiveRecord::Migration
  def change
  	add_column :users, :username, :string, null: false, unique: true, default: (0...8).map { ('a'..'z').to_a[rand(26)] }.join
  end

end
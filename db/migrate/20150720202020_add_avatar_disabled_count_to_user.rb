class AddAvatarDisabledCountToUser < ActiveRecord::Migration
  def change
  	add_column :users, :avatar_disabled_count, :integer
  end
end
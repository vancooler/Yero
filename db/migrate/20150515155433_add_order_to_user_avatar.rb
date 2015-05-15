class AddOrderToUserAvatar < ActiveRecord::Migration
  def change
  	add_column :user_avatars, :order, :integer
  end
end

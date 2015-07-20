class RemoveEmailIndexFromVenue < ActiveRecord::Migration
  def change

    remove_index :venues, :email
  end
end

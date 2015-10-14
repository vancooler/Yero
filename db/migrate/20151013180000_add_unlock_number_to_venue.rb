class AddUnlockNumberToVenue < ActiveRecord::Migration
  def change
  	add_column :venues, :unlock_number, :integer
  end
end

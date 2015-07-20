class RemoveKeyIndexFromUser < ActiveRecord::Migration
  def change

    remove_index :users, :key
  end
end

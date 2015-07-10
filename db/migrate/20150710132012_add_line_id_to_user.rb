class AddLineIdToUser < ActiveRecord::Migration
  def change
  	add_column :users, :line_id, :string
  end
end
class AddVersionToUser < ActiveRecord::Migration
  def change
  	add_column :users, :version, :string
  end
end
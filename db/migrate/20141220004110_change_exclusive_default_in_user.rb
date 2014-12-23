class ChangeExclusiveDefaultInUser < ActiveRecord::Migration
  def change
  	change_column :users, :exclusive, :boolean, :default => false
  end
end

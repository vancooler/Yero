class AddSublocalityToUser < ActiveRecord::Migration
  def change
  	add_column :users, :current_sublocality, :string
  end
end


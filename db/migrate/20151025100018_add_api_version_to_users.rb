class AddApiVersionToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :api_verstion, :float, default: 1
  end
end


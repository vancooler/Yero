class AddAcceptContractToUser < ActiveRecord::Migration
  def change
  	add_column :users, :accept_contract, :boolean, default: false
  end
end

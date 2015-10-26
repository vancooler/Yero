class ChangeApiVersionToStatusDisabledCountInUsers < ActiveRecord::Migration
  def change
	rename_column :users, :api_verstion, :status_disabled_count
	change_column :users, :status_disabled_count, :integer, default: 0
  end
end


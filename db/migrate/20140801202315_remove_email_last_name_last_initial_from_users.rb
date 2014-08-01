class RemoveEmailLastNameLastInitialFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :email
    remove_column :users, :last_initial
  end
end

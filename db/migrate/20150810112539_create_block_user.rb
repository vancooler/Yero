class CreateBlockUser < ActiveRecord::Migration
  def change
    create_table :block_users do |t|
      t.integer     :target_user_id,              null: false
      t.integer     :origin_user_id,               null: false
    end


    add_index :block_users, [:target_user_id, :origin_user_id] 
  end
  
end

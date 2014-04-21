class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.date   :birthday,           null: false
      t.string :first_name,         null: false
      t.string :last_initial,       null: false
      t.string :gender,             null: false
      t.string :key,                null: false

      t.datetime :last_activity
      t.timestamps
    end

    add_index :users, :email,                unique: true
    add_index :users, :key,                  unique: true

    add_attachment :users, :avatar
  end
end

class CreateWhispers < ActiveRecord::Migration
  def change
    create_table :whispers do |t|
      t.integer :origin_id
      t.integer :target_id
      t.boolean :viewed, default: false
      t.boolean :accepted, default: false

      t.timestamps
    end
    add_index :whispers, :origin_id
    add_index :whispers, :target_id
  end
end

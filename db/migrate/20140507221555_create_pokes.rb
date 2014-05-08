class CreatePokes < ActiveRecord::Migration
  def change
    create_table :pokes do |t|
      t.integer :poker_id
      t.integer :pokee_id
      t.datetime :poked_at, default: Time.now
      t.boolean :viewed, default: false
    end
  end
end

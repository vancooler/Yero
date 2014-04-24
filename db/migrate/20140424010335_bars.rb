class Bars < ActiveRecord::Migration
  def change
    create_table(:bars) do |t|
      t.integer :beacon_id,               null: false
      t.integer :room_id,                 null: false
      t.boolean :open,                    null: false, default: false
      t.integer :current_serving_number,  null: false, default: 0
      t.integer :current_ticket_number,   null: false, default: 0
    end

    create_table(:ticket) do |t|
      t.integer :bar_id,               null: false
      t.integer :user_id,              null: false
      t.integer :ticket_number,        null: false
    end
  end
end

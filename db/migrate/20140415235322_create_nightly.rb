class CreateNightly < ActiveRecord::Migration
  def change
    create_table :nightlies do |t|
      t.integer          :venue_id,            null: false
      t.integer          :girl_count,          default: 0
      t.integer          :boy_count,           default: 0
      t.integer          :guest_wait_time,     default: 0
      t.integer          :regular_wait_time,   default: 0
      t.integer          :current_fill,        default: 0
      t.timestamps
    end
  end
end

class Peopls < ActiveRecord::Migration
  def change
    create_table(:participants) do |t|
      t.integer     :room_id,               null: false
      t.integer     :user_id,               null: false
      t.datetime    :last_activity,         null: false,     default: Time.now
      t.datetime    :enter_time,            null: false,     default: Time.now
    end
  end
end

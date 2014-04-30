class Lotto < ActiveRecord::Migration
  def change
    create_table(:winners) do |t|
      t.integer     :user_id,               null: false
      t.string      :message,               null: false
      t.integer     :venue_id,              null: false

      t.timestamps
    end
  end
end

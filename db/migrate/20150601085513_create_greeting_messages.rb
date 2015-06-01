class CreateGreetingMessages < ActiveRecord::Migration
  def change
    create_table :greeting_messages do |t|
      t.integer :weekday_id
      t.integer :venue_id
      t.string  :first_dj
      t.string  :second_dj
      t.string  :last_call
      t.float   :admission_fee
      t.string  :drink_special
      t.text    :description
      t.timestamps
    end

    add_index :greeting_messages, :venue_id

  end
end

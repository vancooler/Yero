class CreateVenues < ActiveRecord::Migration
  def change
    create_table(:venues) do |t|
      t.string :email

      t.string   :name
      t.string   :address_line_one
      t.string   :address_line_two
      t.string   :city
      t.string   :state
      t.string   :country
      t.string   :zipcode
      t.string   :phone
      t.string   :dress_code
      t.integer  :age_requirement
      t.integer  :venue_type_id

      t.timestamps
    end

    add_index :venues, :email,                unique: true
    add_index :venues, :venue_type_id

    create_table(:business_hours) do |t|
      t.integer :venue_id,      null: false
      t.integer :day,           null: false
      t.time    :open_time,     null: false
      t.time    :close_time,    null: false
    end
  end
end

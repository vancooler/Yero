class DeviseCreateVenues < ActiveRecord::Migration
  def change
    create_table(:venues) do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

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

      t.timestamps
    end

    add_index :venues, :email,                unique: true
    add_index :venues, :reset_password_token, unique: true

    create_table(:business_hours) do |t|
      t.integer :venue_id,      null: false
      t.integer :day,           null: false
      t.time    :open_time,     null: false
      t.time    :close_time,    null: false
    end
  end
end

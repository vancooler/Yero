class CreateEarlyVenues < ActiveRecord::Migration
  def change
    create_table :early_venues do |t|
      t.string :username
      t.string :city
      t.string :job_title
      t.string :phone
      t.string :email
      t.string :venue_name

      t.timestamps
    end
  end
end

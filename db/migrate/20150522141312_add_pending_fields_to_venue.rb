class AddPendingFieldsToVenue < ActiveRecord::Migration
  def change
  	add_column :venues, :manager_first_name, :string
  	add_column :venues, :manager_last_name, :string
  	add_column :venues, :manager_phone, :string
  	add_column :venues, :pending_manager_first_name, :string
  	add_column :venues, :pending_manager_last_name, :string
  	add_column :venues, :pending_manager_phone, :string
  	add_column :venues, :pending_name, :string
  	add_column :venues, :pending_phone, :string
  	add_column :venues, :pending_email, :string
  	add_column :venues, :pending_venue_type_id, :integer
  	add_column :venues, :pending_venue_network_id, :integer
  	add_column :venues, :pending_address, :string
  	add_column :venues, :pending_city, :string
  	add_column :venues, :pending_state, :string
  	add_column :venues, :pending_country, :string
  	add_column :venues, :pending_zipcode, :string
  	add_column :venues, :pending_latitude, :float
  	add_column :venues, :pending_longitude, :float
  end
end

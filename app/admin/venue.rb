ActiveAdmin.register Venue do
  permit_params :email, :name, :venue_type, :venue_type_id, :venue_network_id, :venue_network, :address_line_one, :address_line_two, :city, :state, :country, :zipcode, :phone, :age_requirement, :latitude, :longitude
  index do
  	column :id
    column :email
    column "Name", :name
    column "Type", :venue_type
    column :venue_network
    column "Address" do |venue|
      (venue.address_line_one.nil? ? '' : venue.address_line_one) + (venue.address_line_two.nil? ? '' : ' ' + venue.address_line_two) + (venue.city.nil? ? '' : ', ' + venue.city)
    end
    # column :address_line_one
    # column :address_line_two
    # column :city
    # column :state
    # column :country
    # column :zipcode
    column :phone
    # column :dress_code
    column :age_requirement
    column :longitude
    column :latitude
    
  	actions
  end
  filter :city, :label => "City", :as => :select, :collection => proc { Venue.where("venues.city IS NOT NULL").collect  { |v| [v.city] }.uniq }
  filter :venue_type
  filter :venue_network

  form do |f|
    f.inputs "Details" do
      f.input :email
      f.input :name, :label => "Name"
      f.input :venue_type
      f.input :venue_network
      f.input :address_line_one
      f.input :address_line_two
      f.input :city
      f.input :state
      f.input :country, :priority_countries => ["CA", "US"]
      f.input :zipcode
      f.input :phone
      # f.input :dress_code
      f.input :age_requirement
      f.input :longitude
      f.input :latitude
    end
    f.actions
  end

  show do |venue|
    attributes_table_for venue do
      row :email
      row :name
      row("Address") { |venue| (venue.address_line_one.nil? ? '' : venue.address_line_one) + (venue.address_line_two.nil? ? '' : ' ' + venue.address_line_two) + (venue.zipcode.nil? ? '' : ' ' + venue.zipcode) + (venue.city.nil? ? '' : ', ' + venue.city) + (venue.state.nil? ? '' : ' ' + venue.state) + (venue.country_name.nil? ? '' : ', ' + venue.country_name) }
      # row :address_line_one
      # row :address_line_two
      # row :city
      # row :state
      # row :country
      # row :zipcode
      row :phone
      row :age_requirement
      row :venue_type
      row :longitude
      row :latitude
      row :venue_network
    end
  end
end

ActiveAdmin.register Venue do
  actions :index, :show, :edit, :destroy, :new, :create, :update
  index do
  	column :id
    column :email
    column :name
    column :address_line_one
    column :address_line_two
    column :city
    column :state
    column :country
    column :zipcode
    column :phone
    column :dress_code
    column :age_requirement
    column :venue_type
    column :longitude
    column :latitude
    column :venue_network
    
  	actions
  end
  filter :city, :label => "City", :as => :select, :collection => proc { Venue.where("venues.city IS NOT NULL").collect  { |c| [c.city] }.uniq }
  filter :venue_type, :label => "Type", :as => :select, :collection => proc { VenueType.all.collect  { |c| [c.name] }.uniq }
  

  form do |f|
    f.inputs "Details" do
      f.input :email
      f.input :name
      f.input :address_line_one
      f.input :address_line_two
      f.input :city
      f.input :state
      
      f.input :zipcode
      f.input :phone
      f.input :dress_code
      f.input :age_requirement
      f.input :venue_type
      f.input :longitude
      f.input :latitude
      f.input :venue_network
    end
    f.actions
  end

  show do |ad|
    attributes_table_for ad do
      row :email
      row :name
      row :address_line_one
      row :address_line_two
      row :city
      row :state
      row :country
      row :zipcode
      row :phone
      row :dress_code
      row :age_requirement
      row :venue_type
      row :longitude
      row :latitude
      row :venue_network
    end
  end
end

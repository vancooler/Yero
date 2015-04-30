ActiveAdmin.register Venue do
  menu :parent => "VENUE"
  permit_params :email, :name, :venue_type, :venue_type_id, :venue_network_id, :venue_network, 
                :address_line_one, :address_line_two, :city, :state, :country, :zipcode, :phone, 
                :age_requirement, :latitude, :longitude, :web_user, :web_user_id,
                beacons_attributes: [:id, :key, :venue_id, :_destroy],
                venue_avatars_attributes: [:id, :avatar, :venue_id, :default, :_destroy]
  
  batch_action :do_something do |selection|
    Venue.find(selection).each do |venue|
      # venue.status = 0
      # venue.save!
    end
    redirect_to :back
  end
  batch_action :destroy, false
  index do
    selectable_column
  	column :id
    column :email
    column "Name", :name
    column "Type", :venue_type
    column "Owner", :web_user
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

    column :age_requirement
    column :longitude
    column :latitude
    column "Place Key" do |v|
      if Beacon.where("venue_id = ?", v.id).size > 0
        ("&bull;"+(Beacon.where("venue_id = ?", v.id).collect{|g| g.key}.join "<br/>&bull;")).html_safe
      end
    end
  	actions
  end
  filter :id
  filter :city, :label => "City", :as => :select, :collection => proc { Venue.where("venues.city IS NOT NULL").collect  { |v| [v.city] }.uniq }
  filter :venue_type
  filter :venue_network
  filter :web_user, :label => "Owner"

  form do |f|
    f.inputs "Details" do
      f.input :email
      f.input :name, :label => "Name"
      f.input :venue_type
      f.input :web_user, :label => "Owner"
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
      # f.input :longitude
      # f.input :latitude
    end
    f.inputs do
      f.has_many :beacons, heading: 'Places', allow_destroy: true, new_record: true do |b|
        b.input :key
      end
    end

    f.inputs do
      f.has_many :venue_avatars, heading: 'Pictures', allow_destroy: true, new_record: true do |b|
        b.input :avatar, :image_preview => true
        b.input :default
      end
    end
    f.actions
  end

  show do |venue|
    attributes_table_for venue do
      row :email
      row :name
      row("Address") { |venue| (venue.address_line_one.nil? ? '' : venue.address_line_one) + (venue.address_line_two.nil? ? '' : ' ' + venue.address_line_two) + (venue.zipcode.nil? ? '' : ' ' + venue.zipcode) + (venue.city.nil? ? '' : ', ' + venue.city) + (venue.state.nil? ? '' : ' ' + venue.state) + (venue.country_name.nil? ? '' : ', ' + venue.country_name) }
      row("Owner") { |venue| venue.web_user }
      # row :address_line_one
      # row :address_line_two
      # row :city
      # row :state
      # row :country
      # row :zipcode
      row :phone
      row :age_requirement
      row :venue_type
      row :venue_network
      row :longitude
      row :latitude
      row("Default Avatar ID") { |venue| link_to venue.default_avatar.id, [ :admin, venue.default_avatar ]  if !venue.default_avatar.nil?}
      row("Default Avatar") { |venue| image_tag(venue.default_avatar.avatar) if !venue.default_avatar.nil?}

      table_for venue.beacons do
        column "Places" do |b|
          b.key
        end
      end

      table_for venue.secondary_avatars.order('id ASC') do
        column "Secondary Avatars ID" do |a|
          link_to a.id, [ :admin, a ]
        end
        column "Secondary Avatars" do |a|
          image_tag(a.avatar)
        end
      end

    end
  end
end

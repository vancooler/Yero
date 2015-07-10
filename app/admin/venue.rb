ActiveAdmin.register Venue do
  menu :parent => "VENUE"
  permit_params :email, :name, :venue_type, :venue_type_id, :venue_network_id, :venue_network, 
                :address_line_one, :address_line_two, :city, :state, :country, :zipcode, :phone, 
                :age_requirement, :latitude, :longitude, :web_user, :web_user_id,
                beacons_attributes: [:id, :key, :venue_id, :_destroy],
                venue_avatars_attributes: [:id, :avatar, :venue_id, :default, :_destroy]
  


  action_item :only => :show do
    if !venue.draft_pending.nil? and venue.draft_pending
      link_to('Approve pending draft', venue_approve_url(:venue => venue), :method => "post", :data => {:confirm => 'Are you sure?'}) 
    end
  end

  batch_action :set_as_featured, :confirm => "Are you sure you want to set all of these as featured?" do |selection|
    Venue.find(selection).each do |venue|
      venue.featured = true
      venue.save!
    end
    redirect_to :back
  end

  batch_action :unset_featured, :confirm => "Are you sure you want to unset all of these from featured?" do |selection|
    Venue.find(selection).each do |venue|
      venue.featured = false
      venue.save!
    end
    redirect_to :back
  end

  batch_action :destroy, false

  scope :all
  scope :pending
  scope :featured
  
  config.sort_order = 'featured_order_asc'
 
  collection_action :sort, :method => :post do
    order = 1
    params[:venue].each do |id|
      venue = Venue.find_by_id(id)
      if !venue.nil? and venue.featured
        venue.featured_order = order
        venue.save!
        order += 1
      end
    end
    render :nothing => true
  end

  index do
    selectable_column
  	column :id
    # column :email
    column "Name", :name
    column "Type", :venue_type
    column "Owner", :web_user
    column :venue_network
    column "Address" do |venue|
      (venue.address_line_one.nil? ? '' : venue.address_line_one) + (venue.address_line_two.nil? ? '' : ' ' + venue.address_line_two) + (venue.city.nil? ? '' : ', ' + venue.city)
    end
    
    column :phone

    # column :age_requirement
    # column :longitude
    # column :latitude
    column "Place Key" do |v|
      if Beacon.where("venue_id = ?", v.id).size > 0
        ("&bull;"+(Beacon.where("venue_id = ?", v.id).collect{|g| g.key}.join "<br/>&bull;")).html_safe
      end
    end
    # column "Pending Update" do |v|
    #   if !v.pending_name.nil? or !v.pending_email.nil? or !v.pending_venue_type_id.nil? or !v.pending_phone.nil? or !v.pending_address.nil? or !v.pending_city.nil? or !v.pending_state.nil? or !v.pending_country.nil? or !v.pending_zipcode.nil? or !v.pending_manager_first_name.nil? or !v.pending_manager_last_name.nil? or !v.pending_latitude.nil? or !v.pending_longitude.nil?
    #     raw('<span class="status_tag yes">Yes</span>')
    #   else
    #     raw('<span class="status_tag no">No</span>')
    #   end
    # end
    column :draft_pending
    column :featured
    # column :featured_order
  	actions


    # venues.each do |v|
    #   v.pending_name = v.name
    #   v.pending_email = v.email
    #   v.pending_phone = v.phone
    #   v.pending_address = v.address_line_one
    #   v.pending_city = v.city
    #   v.pending_state = v.state
    #   v.pending_zipcode = v.zipcode
    #   v.pending_country = v.country
    #   v.pending_manager_first_name = v.manager_first_name
    #   v.pending_manager_last_name = v.manager_last_name
    #   v.pending_venue_type_id = v,venue_type_id
    # end

  end
  filter :id
  filter :city, :label => "City", :as => :select, :collection => proc { Venue.where("venues.city IS NOT NULL").collect  { |v| [v.city] }.uniq }
  filter :venue_type
  filter :venue_network
  filter :web_user, :label => "Owner" 
  filter :draft_pending

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
    div :class => "table" do 
      table do
        tr do
          th "Attributes"
          th "Live Info"
          th "Pending Info" if venue.draft_pending
        end
        tr do
          td "Name"
          td venue.name
          td venue.pending_name
        end
        tr do
          td "Type"
          td venue.venue_type.name if venue.venue_type
          td VenueType.find_by_id(venue.pending_venue_type_id).name if VenueType.find_by_id(venue.pending_venue_type_id)
        end
        tr do
          td "Email"
          td venue.email
          td venue.pending_email
        end
        tr do
          td "Phone"
          td venue.phone
          td venue.pending_phone
        end
        tr do
          td "Manager_first_name"
          td venue.manager_first_name
          td venue.pending_manager_first_name
        end
        tr do
          td "Manager_last_name"
          td venue.manager_last_name
          td venue.pending_manager_last_name
        end
        tr do
          td "Address"
          td venue.address_line_one
          td venue.pending_address
        end
        tr do
          td "City"
          td venue.city
          td venue.pending_city
        end
        tr do
          td "State"
          td venue.state
          td venue.pending_state
        end
        tr do
          td "Zipcode"
          td venue.zipcode
          td venue.pending_zipcode
        end
        tr do
          td "Country"
          td venue.country
          td venue.pending_country
        end
        tr do
          td "Logo"
          td venue.venue_logos.where(pending: false).empty? ? '' : image_tag(venue.venue_logos.where(pending: false).first.avatar.url, height:100, width:100, :style => "border-radius:10px")
          td venue.venue_logos.where(pending: true).empty? ? '' : image_tag(venue.venue_logos.where(pending: true).first.avatar.url, height:100, width:100, :style => "border-radius:10px")
        end
        # tr do
        #   td "Latitude"
        #   td venue.latitude
        #   td venue.pending_latitude
        # end
        # tr do
        #   td "Longitude"
        #   td venue.longitude
        #   td venue.pending_longitude
        # end
      end
    end

    attributes_table_for venue do
      
      # row("Address") { |venue| (venue.address_line_one.nil? ? '' : venue.address_line_one) + (venue.address_line_two.nil? ? '' : ' ' + venue.address_line_two) + (venue.zipcode.nil? ? '' : ' ' + venue.zipcode) + (venue.city.nil? ? '' : ', ' + venue.city) + (venue.state.nil? ? '' : ' ' + venue.state) + (venue.country_name.nil? ? '' : ', ' + venue.country_name) }
      row("Owner") { |venue| venue.web_user }
      row :age_requirement
      row :venue_network
      row :latitude
      row :longitude
      
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

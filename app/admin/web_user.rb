ActiveAdmin.register WebUser do
  menu :parent => "USERS"
  permit_params :email, :web_user_name, :first_name, :last_name, :business_name, :business_phone, :address_line_1, :address_line_2, :city, :state, :country, :zipcode, :password, :password_confirmation
  #               beacons_attributes: [:id, :key, :venue_id, :_destroy],
  #               venue_avatars_attributes: [:id, :avatar, :venue_id, :default, :_destroy]
  

  controller do
    def update_resource(object, attributes)
      update_method = attributes.first[:password].present? ? :update_attributes : :update_without_password
      object.send(update_method, *attributes)
    end
  end

  
  batch_action :do_something do |selection|
    WebUser.find(selection).each do |venue|
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
    column "Name", :web_user_name
    # column "Type", :venue_type
    # column :venue_network
    column "Address" do |venue|
      (venue.address_line_1.nil? ? '' : venue.address_line_1) + (venue.address_line_2.nil? ? '' : ' ' + venue.address_line_2) + (venue.city.nil? ? '' : ', ' + venue.city)
    end
    # # column :address_line_one
    # # column :address_line_two
    # # column :city
    # # column :state
    # # column :country
    # # column :zipcode
    column :business_phone

    # column :age_requirement
    # column :longitude
    # column :latitude
    # column "Place Key" do |v|
    #   if Beacon.where("venue_id = ?", v.id).size > 0
    #     ("&bull;"+(Beacon.where("venue_id = ?", v.id).collect{|g| g.key}.join "<br/>&bull;")).html_safe
    #   end
    # end
  	actions
  end
  filter :id
  filter :city, :label => "City", :as => :select, :collection => proc { Venue.where("venues.city IS NOT NULL").collect  { |v| [v.city] }.uniq }
  # filter :venue_type
  # filter :venue_network

  form do |f|
    f.inputs "Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :web_user_name

      f.input :business_name
      f.input :first_name
      f.input :last_name
      f.input :address_line_1
      f.input :address_line_2
      f.input :city
      f.input :state
      f.input :country, :priority_countries => ["CA", "US"]
      f.input :zipcode
      f.input :business_phone
    #   # f.input :dress_code
    #   f.input :age_requirement
    #   # f.input :longitude
    #   # f.input :latitude
    # end
    # f.inputs do
    #   f.has_many :beacons, heading: 'Places', allow_destroy: true, new_record: true do |b|
    #     b.input :key
    #   end
    # end

    # f.inputs do
    #   f.has_many :venue_avatars, heading: 'Pictures', allow_destroy: true, new_record: true do |b|
    #     b.input :avatar, :image_preview => true
    #     b.input :default
    #   end
    end
    f.actions
  end

  show do |web_user|
    attributes_table_for web_user do
      row :email
      row :web_user_name
      row("Address") { |web_user| (web_user.address_line_1.nil? ? '' : web_user.address_line_1) + (web_user.address_line_2.nil? ? '' : ' ' + web_user.address_line_2) + (web_user.zipcode.nil? ? '' : ' ' + web_user.zipcode) + (web_user.city.nil? ? '' : ', ' + web_user.city) + (web_user.state.nil? ? '' : ' ' + web_user.state) + (web_user.country_name.nil? ? '' : ', ' + web_user.country_name) }
      # # row :address_line_one
      # # row :address_line_two
      # # row :city
      # # row :state
      # # row :country
      # # row :zipcode
      row :business_phone
      # row :age_requirement
      # row :venue_type
      # row :venue_network
      # row :longitude
      # row :latitude
      # row("Default Avatar ID") { |venue| link_to venue.default_avatar.id, [ :admin, venue.default_avatar ]  if !venue.default_avatar.nil?}
      # row("Default Avatar") { |venue| image_tag(venue.default_avatar.avatar) if !venue.default_avatar.nil?}

      # table_for venue.beacons do
      #   column "Places" do |b|
      #     b.key
      #   end
      # end

      # table_for venue.secondary_avatars.order('id ASC') do
      #   column "Secondary Avatars ID" do |a|
      #     link_to a.id, [ :admin, a ]
      #   end
      #   column "Secondary Avatars" do |a|
      #     image_tag(a.avatar)
      #   end
      # end

    end
  end
end

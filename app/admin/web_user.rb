ActiveAdmin.register WebUser, :as => "Venue Owner" do
  menu :parent => "USERS", :if => proc { !current_admin_user.level.nil? and current_admin_user.level == 0 }
  before_filter :check_super

  controller do
    def check_super
      redirect_to admin_root_path, :notice => "You do not have access to this page" unless !current_admin_user.level.nil? and current_admin_user.level == 0
    end
  end
  
  permit_params :email, :web_user_name, :first_name, :last_name, :business_name, :business_phone, :address_line_1, :address_line_2, :city, :state, :country, :zipcode, :password, :password_confirmation, venue_ids: []
  #               beacons_attributes: [:id, :key, :venue_id, :_destroy],
  #               venue_avatars_attributes: [:id, :avatar, :venue_id, :default, :_destroy]
  
  # before_update do |web_user|
  #   puts "VENUE IDS: "
  #   puts web_user.venue_ids
  # end


  controller do
    def update_resource(object, attributes)
      puts "attributes: "
      puts attributes
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
    column "Full Name" do |web_user|
      (web_user.first_name.blank? ? '' : web_user.first_name + ' ') + (web_user.last_name.blank? ? '' : web_user.last_name)
    end
    column :business_name
   
    column "Phone", :business_phone 

    
  	actions
  end
  filter :id
  filter :city, :label => "City", :as => :select, :collection => proc { Venue.where("venues.city IS NOT NULL").collect  { |v| [v.city] }.uniq }

  form do |f|
    f.inputs "Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation

      f.input :venues, as: :select, collection: Venue.all.order("id DESC").map{|v| ["#{v.name} #{'('+v.web_user.name+')' if !v.web_user.nil?}", v.id]}, multiple: true, include_hidden: false, input_html: { name: "web_user[venue_ids][]" }
      f.input :business_name, :label => "Businiss Name"
      f.input :first_name
      f.input :last_name
      
      f.input :business_phone, :phone => "Phone"
    
    end
    f.actions
  end

  show do |web_user|
    attributes_table_for web_user do
      row :email
      row("Name") { |wu| wu.name }
      row("Business Name") { |wu| wu.business_name }
      row("Phone") { |wu| wu.business_phone }

      table_for web_user.venues do
        column "Venues" do |v|
          link_to v.name, [ :admin, v ]
        end
      end

    end
  end
end

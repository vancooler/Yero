ActiveAdmin.register VenueAvatar do
  menu :parent => "VENUE", :if => proc { !current_admin_user.level.nil? and current_admin_user.level == 0 }
  before_filter :check_super

  controller do
    def check_super
      redirect_to admin_root_path, :notice => "You do not have access to this page" unless !current_admin_user.level.nil? and current_admin_user.level == 0
    end
  end
  permit_params :venue, :default, :avatar, :venue_id
  
  index do
  	column :id
    column :avatar do |avatar|
      image_tag avatar.avatar.url
    end
    column :venue
    column "Is default", :default
  	actions
  end
  filter :venue
  filter :default

  form do |f|
    f.inputs "Details" do
      f.input :venue
      f.input :avatar, :image_preview => true
      f.input :default
      
    end
    f.actions
  end

  show do |venue|
    attributes_table_for venue do
      row :venue
      row :avatar do
          image_tag(venue.avatar)
      end
      row :default
    end
  end
end

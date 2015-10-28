ActiveAdmin.register ActiveInVenue do
  menu :parent => "Activity", :if => proc { !current_admin_user.level.nil? and current_admin_user.level == 0 }

  permit_params :user_id, :user, :venue_id, :venue, :beacon_id, :beacon, :enter_time, :last_activity

  before_filter :check_super

  controller do
    def check_super
      redirect_to admin_root_path, :notice => "You do not have access to this page" unless !current_admin_user.level.nil? and current_admin_user.level == 0
    end
  end

  actions :index, :create, :new, :show, :update, :edit
  index do
  	column :id
    column "User (ID)", :user
    column :venue
    column "Beacon", :beacon do |aiv|
      aiv.beacon.nil? ? '' : aiv.beacon.key
    end
    column :enter_time
    column :last_activity
    
  	actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :user, :label => "User (ID)"
      f.input :venue
      f.input :beacon, as: :select, collection: Beacon.all.order("id DESC").map{|v| ["#{v.key}", v.id]}, include_hidden: false, input_html: { name: "active_in_venue[beacon_id]" }
      f.input :enter_time
      f.input :last_activity
    end
    f.actions
  end

end

ActiveAdmin.register VenueNetwork, :as => "City Network" do
  menu :parent => "VENUE", :if => proc { !current_admin_user.level.nil? and current_admin_user.level == 0 }
  before_filter :check_super

  controller do
    def check_super
      redirect_to admin_root_path, :notice => "You do not have access to this page" unless !current_admin_user.level.nil? and current_admin_user.level == 0
    end
  end
  permit_params :name, :timezone
  index do
  	column :id
    column "Name", :name
    column :timezone
    
  	actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :name, :label => "Name"
      f.input :timezone
    end
    f.actions
  end

  show do |venue|
    attributes_table_for venue do
      row :name
      row :timezone
    end
  end
end

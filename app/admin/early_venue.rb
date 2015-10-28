ActiveAdmin.register EarlyVenue do

  menu :if => proc { !current_admin_user.level.nil? and current_admin_user.level == 0 }

  before_filter :check_super

  controller do
    def check_super
      redirect_to admin_root_path, :notice => "You do not have access to this page" unless !current_admin_user.level.nil? and current_admin_user.level == 0
    end
  end

  actions :index, :show
  index do
  	column :id
    column :email
    column :username
    column :city
    column :venue_name
    column :job_title
    column :phone
    # column :position do |project|
    #  best_in_place project, :position, :type => :input,:path =>[:admin,project]
    # end

    # column :is_active
    
  	actions
  end
  filter :city, :label => "City", :as => :select, :collection => proc { EarlyVenue.all.collect  { |c| [c.city] }.uniq }
  

  show do |ad|
    attributes_table_for ad do
      row :email
      row :username
      row :city
      row :venue_name 
      row :job_title 
      row :phone 
    end
  end
end

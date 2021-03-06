ActiveAdmin.register BetaSignupUser do
  menu :parent => "USERS", :if => proc { !current_admin_user.level.nil? and current_admin_user.level == 0 }
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
    column :phone_type
    column :city
    column :phone_model
    column :created_at
    # column :position do |project|
    #  best_in_place project, :position, :type => :input,:path =>[:admin,project]
    # end

    # column :is_active
    
  	actions
  end
  filter :phone_type, :label => "Phone Type", :as => :select, :collection => proc { BetaSignupUser.all.collect  { |c| [c.phone_type] }.uniq }
  filter :city, :label => "City", :as => :select, :collection => proc { BetaSignupUser.all.collect  { |c| [c.city] }.uniq }
  filter :phone_model, :label => "Phone Model", :as => :select, :collection => proc { BetaSignupUser.all.collect  { |c| [c.phone_model] }.uniq }
  

  show do |ad|
    attributes_table_for ad do
      row :email
      row :phone_type
      row :city
      row :phone_model 
    end
  end
end

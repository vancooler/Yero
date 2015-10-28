ActiveAdmin.register ReportType do
  menu :parent => "REPORT", :if => proc { !current_admin_user.level.nil? and current_admin_user.level == 0 }
  before_filter :check_super

  controller do
    def check_super
      redirect_to admin_root_path, :notice => "You do not have access to this page" unless !current_admin_user.level.nil? and current_admin_user.level == 0
    end
  end
  permit_params :report_type_name

  actions :index, :create, :new, :show, :update, :edit
  index do
  	column :id
    column "Type", :report_type_name
    
  	actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :report_type_name, :label => "Type"
      
    end
    f.actions
  end

  show do |venue|
    attributes_table_for venue do
      row :report_type_name
    end
  end
end

ActiveAdmin.register NotificationPreference do
  menu :parent => "USERS", :if => proc { !current_admin_user.level.nil? and current_admin_user.level == 0 }
  before_filter :check_super

  controller do
    def check_super
      redirect_to admin_root_path, :notice => "You do not have access to this page" unless !current_admin_user.level.nil? and current_admin_user.level == 0
    end
  end

  permit_params :name
  
  index do
  	column :id
    column "Type", :name
    column "Default", :default_value
  	actions
  end
  filter :is_active

  form do |f|
    f.inputs "Details" do
      f.input :name, :label => "Type"
      f.input :default_value
    end
    f.actions
  end

  show do |np|
    attributes_table_for np do
      row 'Type' do
          np.name
      end
      row 'Default' do
          np.default_value
      end
    end
  end
end

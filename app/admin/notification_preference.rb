ActiveAdmin.register NotificationPreference do
  menu :parent => "USERS"

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

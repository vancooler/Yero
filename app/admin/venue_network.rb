ActiveAdmin.register VenueNetwork, :as => "City Network" do
  menu :parent => "VENUE"
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

ActiveAdmin.register VenueType do
  permit_params :name
  index do
  	column :id
    column "Name", :name
    
  	actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :name, :label => "Name"
      
    end
    f.actions
  end

  show do |venue|
    attributes_table_for venue do
      row :name
    end
  end
end

ActiveAdmin.register ShoutReportType do
  menu :parent => "REPORT"
  permit_params :name

  actions :index, :create, :new, :show, :update, :edit
  index do
  	column :id
    column "Type", :name
    
  	actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :name, :label => "Type"
      
    end
    f.actions
  end

  show do |venue|
    attributes_table_for venue do
      row :name
    end
  end
end

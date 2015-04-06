ActiveAdmin.register ReportType do
  menu :parent => "REPORT"
  permit_params :report_type_name
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

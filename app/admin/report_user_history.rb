ActiveAdmin.register ReportUserHistory do
  menu :parent => "REPORT"
  actions :index, :show
  index do
  	column :id
    column :reporting_user
    column :reported_user
    column :report_type
  	actions
  end

  filter :report_type

  show do |venue|
    attributes_table_for venue do
      row :reporting_user
      row :reported_user
      row :report_type
      row :reason
    end
  end
end

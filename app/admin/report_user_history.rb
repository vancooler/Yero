ActiveAdmin.register ReportUserHistory do
  menu :parent => "REPORT"
  actions :index, :show
  def scoped_collection
    super.includes :reported_user # prevents N+1 queries to your database
  end
  index do
  	column :id
    column :reporting_user
    column :reported_user, sortable: "reported_user_id"
    column :report_type
  	actions
  end

  filter :report_type
  filter :reported_user

  show do |venue|
    attributes_table_for venue do
      row :reporting_user
      row :reported_user
      row :report_type
      row :reason
    end
  end
end

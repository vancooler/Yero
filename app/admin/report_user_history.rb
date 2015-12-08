ActiveAdmin.register ReportUserHistory, :as => "User Report History" do
  menu :parent => "REPORT"
  actions :index, :show
  config.sort_order = 'updated_at_desc'
  def scoped_collection
    super.includes :reported_user, :reporting_user # prevents N+1 queries to your database
  end

  controller do
    def scoped_collection
      array = ReportUserHistory.all.select("id, reported_user_id, report_type_id, updated_at").group_by { |x| [x.reported_user_id, x.report_type_id] }.map {|x,y|y.max_by {|x| x['updated_at']}}
      id_array = Array.new
      array.each do |a|
        id_array << a.id
      end
      ReportUserHistory.where(:id => id_array)
    end
  end 

  index do
  	column :id
    # column :reporting_user
    column :reported_user, sortable: "reported_user_id"
    column :report_type
    column "Reported Count",:frequency, sortable: "frequency"
    column "Recent Report Time", :updated_at, sortable: "updated_at"
    column "Recent Notify Time", :notified_at, sortable: "notified_at"
  	actions
  end

  filter :report_type
  filter :reported_user

  show do |history|
    attributes_table_for history do
      row :reported_user
      # row :report_type
      row("Reported Count") { |history| history.frequency}
      row :updated_at
      row :notified_at
      puts history.all_reporting_users
      table_for history.all_reporting_users.order('updated_at DESC') do
        column "Reporting User" do |a|
          link_to a.reporting_user.name, [ :admin, a.reporting_user ]
        end
        column "Report Type" do |a|
          a.report_type.name
        end
        column "Reported at" do |a|
          a.updated_at
        end
        column "Reason" do |a|
          a.reason
        end
      end
    end
  end
end

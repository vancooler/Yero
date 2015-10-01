ActiveAdmin.register ShoutReportHistory do
  menu :parent => "REPORT"
  actions :index, :show
  config.sort_order = 'frequency_desc'
  def scoped_collection
    super.includes :reporter, :reportable # prevents N+1 queries to your database
  end

  controller do
    def scoped_collection
      array = ShoutReportHistory.all.select("id, reportable_type, reportable_id, shout_report_type_id, updated_at").group_by { |x| [x.reportable_type, x.reporter_id, x.shout_report_type_id] }.map {|x,y|y.max_by {|x| x['updated_at']}}
      id_array = Array.new
      array.each do |a|
        id_array << a.id
      end
      ShoutReportHistory.where(:id => id_array)
    end
  end 

  index do
  	column :id
    # column :reporting_user
    column :reporter, sortable: "reporter_id"
    column "Report Type", :shout_report_type
    column "Type", :reportable_type
    column :shout_report_type
    column "Reported Count",:frequency, sortable: "frequency"
    column "Recent Report Time", :updated_at, sortable: "updated_at"
    column "Recent Solved Time", :solved_at, sortable: "solved_at"
  	actions
  end

  filter :shout_report_type

  show do |history|
    attributes_table_for history do
      row :reportable_type

      row("Type") { |history| history.reportable_type}
      row("Reported Item") { |history| history.reportable}
      row("Reported Count") { |history| history.frequency}
      row("Recent Solved Time") { |history| history.solved_at}

      table_for history.all_reporter.order('updated_at DESC') do
        column "Reporting User" do |a|
          link_to a.reporter.name, [ :admin, a.reporting_user ]
        end
        column "Report Type" do |a|
          a.shout_report_type.name
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

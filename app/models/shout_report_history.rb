class ShoutReportHistory < ActiveRecord::Base
  belongs_to :shout_report_type
  belongs_to :reporter, class_name: "User"
  belongs_to :reportable, polymorphic: true

  def all_reporter
  	ShoutReportHistory.includes("reporter").where("reportable_type = ? AND reportable_id = ?", self.reportable_type, self.reportable_id)
  
  end
end

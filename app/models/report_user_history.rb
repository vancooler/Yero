class ReportUserHistory < ActiveRecord::Base
  belongs_to :report_type
  belongs_to :reporting_user, class_name: "User"
  belongs_to :reported_user, class_name: "User"


  def all_reporting_users
  	ReportUserHistory.includes("reporting_user").where("reported_user_id = ?", self.reported_user_id)
  end


  def self.notify_all_users(user_id)
  	all_history = ReportUserHistory.where("reported_user_id = ?", user_id)
  	all_history.update_all(:notified_at => Time.now)
  end
end

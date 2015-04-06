class ReportUserHistory < ActiveRecord::Base
  belongs_to :report_type
  belongs_to :reporting_user, class_name: "User"
  belongs_to :reported_user, class_name: "User"
end

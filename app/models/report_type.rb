class ReportType < ActiveRecord::Base
  validates_presence_of :report_type_name
  has_many :report_user_histories
end

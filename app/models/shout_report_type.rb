class ShoutReportType < ActiveRecord::Base
  validates_presence_of :name
  has_many :shout_report_histories, dependent: :destroy

  
end

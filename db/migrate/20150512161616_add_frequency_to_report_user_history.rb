class AddFrequencyToReportUserHistory < ActiveRecord::Migration
  def change
  	add_column :report_user_histories, :frequency, :integer
  end
end

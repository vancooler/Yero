class AddNotifiedAtToReportUserHistory < ActiveRecord::Migration
  def change
  	add_column :report_user_histories, :notified_at, :datetime
  end
end

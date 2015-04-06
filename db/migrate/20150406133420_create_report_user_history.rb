class CreateReportUserHistory < ActiveRecord::Migration
  def change
    create_table :report_user_histories do |t|
    	t.integer :reporting_user_id
    	t.integer :reported_user_id
    	t.integer :report_type_id
    	t.text :reason
    	t.timestamps
    end
  end
end

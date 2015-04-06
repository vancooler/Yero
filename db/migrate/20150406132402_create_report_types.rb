class CreateReportTypes < ActiveRecord::Migration
  def change
    create_table :report_types do |t|
    	t.string :report_type_name
    	t.timestamps
    end
  end
end

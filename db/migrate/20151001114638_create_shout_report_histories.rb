class CreateShoutReportHistories < ActiveRecord::Migration
  def change
  	create_table :shout_report_histories do |t|
      t.integer :shout_report_type_id
      t.text    :reason
      t.integer :reportable_id
      t.string  :reportable_type
      t.integer :reporter_id
      t.integer :frequency
      t.datetime :solved_at

      t.timestamps
    end

  end
end
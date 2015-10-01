class CreateShoutReportTypes < ActiveRecord::Migration
  def change
    create_table :shout_report_types do |t|
      t.string :name

      t.timestamps
    end

    
    ShoutReportType.create(name: "Offensive content")
    ShoutReportType.create(name: "This post targets someone")
    ShoutReportType.create(name: "Spam")
    ShoutReportType.create(name: "Other")
  end
end

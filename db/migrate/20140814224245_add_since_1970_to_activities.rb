class AddSince1970ToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :since_1970, :integer
  end
end

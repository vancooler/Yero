class CreateReportedUsers < ActiveRecord::Migration
  def change
    create_table :reported_users do |t|
    	t.string :first_name
    	t.string :key
    	t.string :apn_token
    	t.string :email
    	t.references :user, index: true
    	t.timestamps
    end
  end
end

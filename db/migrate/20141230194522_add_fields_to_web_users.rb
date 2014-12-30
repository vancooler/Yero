class AddFieldsToWebUsers < ActiveRecord::Migration
  def change
  	add_column :web_users, :web_user_name, :string
  	add_column :web_users, :job_title, :string
  	add_column :web_users, :venue_name, :string
  end
end
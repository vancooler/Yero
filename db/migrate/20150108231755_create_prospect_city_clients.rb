class CreateProspectCityClients < ActiveRecord::Migration
  def change
    create_table :prospect_city_clients do |t|
    	t.string :email
    	t.float :longitude
    	t.float :latitude
      	t.timestamps
    end
  end
end

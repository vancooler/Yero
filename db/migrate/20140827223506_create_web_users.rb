class CreateWebUsers < ActiveRecord::Migration
  def change
    create_table :web_users do |t|
      t.string :first_name
      t.string :last_name
      t.string :business_name
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :state
      t.string :country
      t.string :zipcode
      t.string :business_phone
      t.string :cell_phone

      t.timestamps
    end
  end
end

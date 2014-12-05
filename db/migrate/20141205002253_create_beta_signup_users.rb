class CreateBetaSignupUsers < ActiveRecord::Migration
  def change
    create_table :beta_signup_users do |t|
      t.string :email,      null: false
      t.string :city
      t.string :phone_model
      t.string :phone_type

      t.timestamps
    end
  end
end

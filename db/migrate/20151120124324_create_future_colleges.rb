class CreateFutureColleges < ActiveRecord::Migration
  def change
    create_table :future_colleges do |t|
        t.integer  :unique_count           
        t.string   :name
        t.text     :user_ids
        t.timestamps
    end

  end
end
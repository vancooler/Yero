class CreateCityNetwork < ActiveRecord::Migration
  def change
    create_table(:city_networks) do |t|
      t.string     :name,               null: false
      t.timestamps
    end
  end
end

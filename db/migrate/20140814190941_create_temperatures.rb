class CreateTemperatures < ActiveRecord::Migration
  def change
    create_table :temperatures do |t|
      t.references :beacon, index: true
      t.integer :celsius

      t.timestamps
    end
  end
end

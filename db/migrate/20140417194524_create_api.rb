class CreateApi < ActiveRecord::Migration
  def change
    create_table :apis do |t|
      t.string :key
    end
  end
end

class CreateShareReference < ActiveRecord::Migration
  def change
    create_table(:share_references) do |t|
      t.string     :name,               null: false
      t.integer     :count,               null: false
      t.timestamps
    end
  end
end

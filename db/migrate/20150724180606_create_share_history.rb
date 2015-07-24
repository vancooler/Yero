class CreateShareHistory < ActiveRecord::Migration
  def change
    create_table(:share_histories) do |t|
      t.integer     :share_reference_id,               null: false
      t.timestamps
    end
  end
end

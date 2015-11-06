class CreateDeletedObject < ActiveRecord::Migration
  def change
    create_table :deleted_objects do |t|
        t.integer  :deleted_object_id,           null: false
        t.string   :deleted_object_type,         default: ""

        t.timestamps
    end

  end
end
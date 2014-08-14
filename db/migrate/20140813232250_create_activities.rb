class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :user, index: true
      t.string :action
      t.references :trackable, polymorphic: true, index: true

      t.timestamps
    end
  end
end

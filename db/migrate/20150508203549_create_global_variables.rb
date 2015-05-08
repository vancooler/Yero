class CreateGlobalVariables < ActiveRecord::Migration
  def change
    create_table :global_variables do |t|
      t.string :name
      t.string :value

      t.timestamps
    end
  end
end

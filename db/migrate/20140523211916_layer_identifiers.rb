class LayerIdentifiers < ActiveRecord::Migration
  def change
    add_column :users, :layer_id, :string
  end
end

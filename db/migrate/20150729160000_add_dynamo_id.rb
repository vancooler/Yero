class AddDynamoId < ActiveRecord::Migration
  def change
  	add_column :recent_activities, :dynamo_id, :string
  	add_column :whisper_todays, :dynamo_id, :string
  end
end
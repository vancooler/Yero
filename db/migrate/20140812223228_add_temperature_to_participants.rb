class AddTemperatureToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :temperature, :integer
  end
end

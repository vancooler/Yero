class RenameRoomType < ActiveRecord::Migration
  def change
    rename_column :beacons, :type, :room_type
  end
end

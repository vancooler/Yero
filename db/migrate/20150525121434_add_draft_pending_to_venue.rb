class AddDraftPendingToVenue < ActiveRecord::Migration
  def change
  	add_column :venues, :draft_pending, :boolean, default: false
  end
end

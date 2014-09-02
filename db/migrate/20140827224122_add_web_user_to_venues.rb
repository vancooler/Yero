class AddWebUserToVenues < ActiveRecord::Migration
  def change
    add_reference :venues, :web_user, index: true
  end
end

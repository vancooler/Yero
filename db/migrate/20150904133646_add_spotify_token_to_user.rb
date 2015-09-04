class AddSpotifyTokenToUser < ActiveRecord::Migration
  def change
  	add_column :users, :spotify_id, :string
  	add_column :users, :spotify_token, :string
  end
end
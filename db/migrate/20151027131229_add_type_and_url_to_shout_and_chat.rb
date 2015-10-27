class AddTypeAndUrlToShoutAndChat < ActiveRecord::Migration
  def change
  	add_column :shouts, :type, :string
  	add_column :shout_comments, :type, :string
  	add_column :shouts, :image_url, :text
  	add_column :shout_comments, :image_url, :text
  	add_column :shouts, :audio_url, :text
  	add_column :shout_comments, :audio_url, :text
  
  	add_column :chatting_messages, :type, :string
  	add_column :chatting_messages, :image_url, :text
  	add_column :chatting_messages, :audio_url, :text
  end
end


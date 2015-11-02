class AddImageThumbUrlToChattingMessage < ActiveRecord::Migration
  def change
  	add_column :chatting_messages, :image_thumb_url, :text
  end
end


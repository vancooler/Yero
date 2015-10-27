class ChangeTypeToContentTypeInShoutAndChat < ActiveRecord::Migration
  def change
	rename_column :shouts, :type, :content_type
	rename_column :shout_comments, :type, :content_type
	rename_column :chatting_messages, :type, :content_type
  end
end


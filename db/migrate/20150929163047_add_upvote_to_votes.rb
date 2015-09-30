class AddUpvoteToVotes < ActiveRecord::Migration
  def change
  	add_column :shout_votes, :upvote, :boolean
  	add_column :shout_comment_votes, :upvote, :boolean
  end
end

class CreateShoutCommentVotes < ActiveRecord::Migration
  def change
    create_table :shout_comment_votes do |t|
      t.references :shout_comment, index: true
      t.references :user
      t.timestamps
    end
  end
end

class ShoutCommentVote < ActiveRecord::Base
  belongs_to :shout_comment
  belongs_to :user




end
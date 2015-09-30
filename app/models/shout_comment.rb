class ShoutComment < ActiveRecord::Base
  belongs_to :shout
  has_many :shout_comment_votes, dependent: :destroy
  belongs_to :user



  def total_upvotes
  	self.shout_comment_votes.where(upvote: true).length - self.shout_comment_votes.where(upvote: false).length
  end


  def change_vote(current_user, upvote)
  	sv = ShoutCommentVote.find_by_shout_comment_id_and_user_id(self.id, current_user.id)
  	if !sv.nil?
  		result = sv.update(upvote: upvote)
  		event = 'change_comment_vote'
  		data = {
  			user_id: current_user.id,
  			vote:    (upvote ? "up" : "down")
  		}

  	else
  		sv = ShoutVote.new(user_id: current_user.id, shout_comment_id: self.id)
  		sv.upvote = upvote
  		result = sv.save
  		event = 'add_comment_vote'
  		data = {
  			user_id: current_user.id,
  			vote:    (upvote ? "up" : "down")
  		}
  	end
  	return {result: result, event: event, data: data}

  end

  # Create a new shout
  def self.create_shout_comment(current_user, body, shout_id)
  	shout_comment = ShoutComment.new
	shout_comment.latitude = current_user.latitude
	shout_comment.longitude = current_user.longitude
  	shout_comment.body = body
  	shout_comment.shout_id = shout_id.to_i
  	shout_comment.user_id = current_user.id
  	result = shout_comment.save
  	if result
	  	return shout_comment
    else
    	return false
    end
  end


  # return shouts list
  def self.list(current_user, order_by, shout_id)
  	shout_comments = ShoutComment.where(shout_id: shout_id).order("created_at DESC")
  	case order_by
  	when 'new'
  		# shout_comments order by created_at
  	when 'hot'
  		# shout_comments order by upvote
  		shout_comments.sort_by{|s| s.total_upvotes}.reverse
  	end

  	return shout_comments
  end
end
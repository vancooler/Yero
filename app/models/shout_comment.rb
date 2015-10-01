class ShoutComment < ActiveRecord::Base
  belongs_to :shout
  has_many :shout_comment_votes, dependent: :destroy
  belongs_to :user



  def total_upvotes
  	self.shout_comment_votes.where(upvote: true).length - self.shout_comment_votes.where(upvote: false).length
  end


  def change_vote(current_user, upvote)
  	scv = ShoutCommentVote.find_by_shout_comment_id_and_user_id(self.id, current_user.id)
  	if !scv.nil?
  		result = scv.update(upvote: upvote)
  		event = 'change_comment_vote'
  		data = {
  			user_id: current_user.id,
  			vote:    (upvote ? "up" : "down")
  		}

  	else
  		scv = ShoutCommentVote.new(user_id: current_user.id, shout_comment_id: self.id)
  		scv.upvote = upvote
  		result = scv.save
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
    	# :nocov:
    	return false
    	# :nocov:
    end
  end


  # return shouts list
  def self.list(current_user, shout_id)
  	shout_comments = ShoutComment.where(shout_id: shout_id).order("created_at DESC")
  	
  	return ShoutComment.shout_comments_json(current_user, shout_comments)
  end

  def self.shout_comments_json(current_user, shout_comments)
  	shout_comment_upvoted_ids = ShoutCommentVote.where(user_id: current_user.id).where(upvote: true).map(&:shout_comment_id)
  	shout_comment_downvoted_ids = ShoutCommentVote.where(user_id: current_user.id).where(upvote: false).map(&:shout_comment_id)
  	return_shout_comments = Jbuilder.encode do |json|
      json.array! shout_comments do |shout_comment|
        json.id 			shout_comment.id
        json.shout_id 		shout_comment.shout_id
        json.body 			shout_comment.body
        json.latitude 		shout_comment.latitude
        json.longitude 		shout_comment.longitude
        json.timestamp 		shout_comment.created_at.to_i
        json.total_votes 	shout_comment.total_upvotes
        json.upvoted 		(shout_comment_upvoted_ids.include? shout_comment.id)
        json.downvoted 		(shout_comment_downvoted_ids.include? shout_comment.id)
        json.author_id 		shout_comment.user_id
      end         
    end
    return_shout_comments = JSON.parse(return_shout_comments).delete_if(&:empty?)
    return return_shout_comments 
  end
end
require 'spec_helper'

describe FriendsController do

	describe "Friends controller" do

		it "send whisper" do
			birthday = (Time.now - 21.years)
			user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: false, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
		    
		    user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746133, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_2 = UserAvatar.create!(id: 2, user: user_3, is_active: true, order: 0)
		    
		    user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", email: "test4@yero.co", password: "123456", birthday: (birthday-20.years), gender: 'F', latitude: 49.3247234, longitude: -123.0706173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_4 = UserAvatar.create!(id: 3, user: user_4, is_active: true, order: 0)

	      	friend = FriendByWhisper.create!(target_user_id: 3, origin_user_id: 2, friend_time: Time.now, viewed: false)
		    
	      	token = user_4.generate_token
	      	request.env["X-API-TOKEN"] = token
	      	get :show, :id => 3
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['data']['code']).to eql 403
	      	expect(JSON.parse(response.body)['data']['message']).to eql "Sorry, you don't have access to it"

	      	token = user_2.generate_token
	      	request.env["X-API-TOKEN"] = token
	      	get :show, :id => 3
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql 3
	      	expect(JSON.parse(response.body)['data']['object']['id']).to eql 3

	      	get :show, :id => 8
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['data']['code']).to eql 404
	      	expect(JSON.parse(response.body)['data']['message']).to eql 'Sorry, cannot find the friend'

	      	get :show, :id => 4
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['data']['code']).to eql 403
	      	expect(JSON.parse(response.body)['data']['message']).to eql "Sorry, you don't have access to it"

	      	# Block
	      	BlockUser.create!(origin_user_id: 2, target_user_id: 3)
	      	token = user_3.generate_token
	      	request.env["X-API-TOKEN"] = token
	      	get :show, :id => 2
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['data']['code']).to eql 403
	      	expect(JSON.parse(response.body)['data']['message']).to eql "Sorry, you don't have access to it"

	      	BlockUser.delete_all
	      	# No photo
	      	UserAvatar.delete_all
	      	token = user_3.generate_token
	      	request.env["X-API-TOKEN"] = token
	      	get :show, :id => 2
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['data']['code']).to eql 403
	      	expect(JSON.parse(response.body)['data']['message']).to eql "Sorry, you don't have access to it"


	      	FriendByWhisper.delete_all
	      	UserAvatar.delete_all
	      	User.delete_all

	    end
	end
end
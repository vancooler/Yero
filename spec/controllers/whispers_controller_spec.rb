require 'spec_helper'

describe WhispersController do

	describe "Whispers controller" do

		it "send whisper" do
			birthday = (Time.now - 21.years)
			user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: false, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
		    
		    user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746133, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_2 = UserAvatar.create!(id: 2, user: user_3, is_active: true, order: 0)
		    
		    user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", email: "test4@yero.co", password: "123456", birthday: (birthday-20.years), gender: 'F', latitude: 49.3247234, longitude: -123.0706173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_4 = UserAvatar.create!(id: 3, user: user_4, is_active: true, order: 0)

		    
	      	token = user_2.generate_token
	      	request.env["X-API-TOKEN"] = token

	      	post :api_create, :notification_type => '2', :target_id => '3', :intro => "Hi!"
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(WhisperToday.count).to eql 1
	      	expect(WhisperSent.count).to eql 1
	      	expect(RecentActivity.count).to eql 2


	      	WhisperToday.delete_all
	      	WhisperSent.delete_all
	      	FriendByWhisper.delete_all
	      	RecentActivity.delete_all
	      	UserAvatar.delete_all
	      	User.delete_all

	    end


	    it "delete whisper" do
			birthday = (Time.now - 21.years)
			user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: false, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
		    
		    user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746133, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_2 = UserAvatar.create!(id: 2, user: user_3, is_active: true, order: 0)
		    
		    user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", email: "test4@yero.co", password: "123456", birthday: (birthday-20.years), gender: 'F', latitude: 49.3247234, longitude: -123.0706173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_4 = UserAvatar.create!(id: 3, user: user_4, is_active: true, order: 0)

	      	token = user_2.generate_token
	      	request.env["X-API-TOKEN"] = token

	      	post :api_create, :notification_type => '2', :target_id => '3', :intro => "Hi!"
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(WhisperToday.count).to eql 1
	      	expect(WhisperToday.first.declined).to eql false
	      	expect(WhisperSent.count).to eql 1
	      	expect(RecentActivity.count).to eql 2



	      	# delete it
	      	token = user_3.generate_token
	      	request.env["X-API-TOKEN"] = token
	      	post :whisper_request_state, :whisper_id => 'aaa2', :declined => '1'
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(WhisperToday.count).to eql 1
	      	expect(WhisperToday.first.declined).to eql true
	      	expect(WhisperSent.count).to eql 1
	      	expect(RecentActivity.count).to eql 2

	      	WhisperToday.delete_all
	      	WhisperSent.delete_all
	      	FriendByWhisper.delete_all
	      	RecentActivity.delete_all
	      	UserAvatar.delete_all
	      	User.delete_all
	    end

	    it "delete whisper array" do
			birthday = (Time.now - 21.years)
			user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: false, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
		    
		    user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746133, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_2 = UserAvatar.create!(id: 2, user: user_3, is_active: true, order: 0)
		    
		    user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", email: "test4@yero.co", password: "123456", birthday: (birthday-20.years), gender: 'F', latitude: 49.3247234, longitude: -123.0706173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_4 = UserAvatar.create!(id: 3, user: user_4, is_active: true, order: 0)

	      	token = user_2.generate_token
	      	request.env["X-API-TOKEN"] = token

	      	post :api_create, :notification_type => '2', :target_id => '3', :intro => "Hi!"
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(WhisperToday.count).to eql 1
	      	expect(WhisperToday.first.declined).to eql false
	      	expect(WhisperSent.count).to eql 1
	      	expect(RecentActivity.count).to eql 2

	      	token = user_4.generate_token
	      	request.env["X-API-TOKEN"] = token

	      	post :api_create, :notification_type => '2', :target_id => '3', :intro => "Hi!"
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(WhisperToday.count).to eql 2
	      	expect(WhisperToday.first.declined).to eql false
	      	expect(WhisperSent.count).to eql 2
	      	expect(RecentActivity.count).to eql 4



	      	# delete it
	      	token = user_3.generate_token
	      	request.env["X-API-TOKEN"] = token
	      	post :decline_whisper_requests, :array => []
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql 'ID array is empty'


	      	post :decline_whisper_requests, :array => ['aaa2', 'aaa4']
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(WhisperToday.count).to eql 2
	      	expect(WhisperToday.first.declined).to eql true
	      	expect(WhisperToday.second.declined).to eql true
	      	expect(WhisperSent.count).to eql 2
	      	expect(RecentActivity.count).to eql 4

	      	WhisperToday.delete_all
	      	WhisperSent.delete_all
	      	FriendByWhisper.delete_all
	      	RecentActivity.delete_all
	      	UserAvatar.delete_all
	      	User.delete_all
	    end

	    it "accept whisper" do
			birthday = (Time.now - 21.years)
			user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: false, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
		    
		    user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746133, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_2 = UserAvatar.create!(id: 2, user: user_3, is_active: true, order: 0)
		    
		    user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", email: "test4@yero.co", password: "123456", birthday: (birthday-20.years), gender: 'F', latitude: 49.3247234, longitude: -123.0706173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_4 = UserAvatar.create!(id: 3, user: user_4, is_active: true, order: 0)

	      	token = user_2.generate_token
	      	request.env["X-API-TOKEN"] = token

	      	post :api_create, :notification_type => '2', :target_id => '3', :intro => "Hi!"
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(WhisperToday.count).to eql 1
	      	expect(WhisperToday.first.declined).to eql false
	      	expect(WhisperSent.count).to eql 1
	      	expect(RecentActivity.count).to eql 2



	      	token = user_3.generate_token
	      	request.env["X-API-TOKEN"] = token

	      	# show a single whisper
	      	get :show, :id => 'aaa2'
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whisper_id']).to eql 'aaa2'
	      	expect(JSON.parse(response.body)['data']['object']['id']).to eql 2

	      	get :show, :id => 'aaaa2'
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['data']['code']).to eql 404
	      	expect(JSON.parse(response.body)['data']['message']).to eql 'Sorry, cannot find the whisper'


	      	# accept it
	      	post :whisper_request_state, :whisper_id => 'aaa2', :accepted => '0'
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql 'There was an error.'

	      	post :whisper_request_state, :whisper_id => 'aaa', :accepted => '1'
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql 'Permission denied.'

	      	
	      	post :whisper_request_state, :whisper_id => 'aaa2', :accepted => '1'
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(WhisperToday.count).to eql 1
	      	expect(WhisperToday.first.accepted).to eql true
	      	expect(WhisperSent.count).to eql 1
	      	expect(RecentActivity.count).to eql 4
	      	expect(FriendByWhisper.count).to eql 1

	      	# Pull Activities
	      	post :chat_request_history, :per_page => 48, :page => 0
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data'].count).to eql 2


	      	# NO access
	      	token = user_4.generate_token
	      	request.env["X-API-TOKEN"] = token
	      	get :show, :id => 'aaa2'
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['data']['code']).to eql 403
	      	expect(JSON.parse(response.body)['data']['message']).to eql "Sorry, you don't have access to it"

	      	# Block
	      	BlockUser.create!(origin_user_id: 2, target_user_id: 3)
	      	token = user_3.generate_token
	      	request.env["X-API-TOKEN"] = token
	      	get :show, :id => 'aaa2'
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['data']['code']).to eql 403
	      	expect(JSON.parse(response.body)['data']['message']).to eql "Sorry, you don't have access to it"

	      	BlockUser.delete_all
	      	# No photo
	      	UserAvatar.delete_all
	      	token = user_3.generate_token
	      	request.env["X-API-TOKEN"] = token
	      	get :show, :id => 'aaa2'
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['data']['code']).to eql 403
	      	expect(JSON.parse(response.body)['data']['message']).to eql "Sorry, you don't have access to it"

	      	
	      	WhisperToday.delete_all
	      	WhisperSent.delete_all
	      	FriendByWhisper.delete_all
	      	RecentActivity.delete_all
	      	User.delete_all
	    end



	    # 1.3 new feature senarios:
	    it "1.3 whispers" do
	    	birthday = (Time.now - 21.years)
			user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: false, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
		    
		    user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746133, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_2 = UserAvatar.create!(id: 2, user: user_3, is_active: true, order: 0)
		    
		    user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", email: "test4@yero.co", password: "123456", birthday: (birthday-20.years), gender: 'F', latitude: 49.3247234, longitude: -123.0706173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_4 = UserAvatar.create!(id: 3, user: user_4, is_active: true, order: 0)

	      	token = user_2.generate_token
	      	request.env["X-API-TOKEN"] = token

	      	# user_2 -> user_3 initial whisper
	      	post :api_create, :notification_type => '2', :target_id => '3', :intro => "Hi!"
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(WhisperToday.count).to eql 1
	      	expect(WhisperToday.first.message).to eql 'Hi!'
	      	expect(WhisperToday.first.message_b).to eql ''
	      	expect(WhisperToday.first.accepted).to eql false
	      	expect(WhisperToday.first.declined).to eql false
	      	expect(WhisperToday.first.paper_owner_id).to eql 3
	      	expect(WhisperReply.count).to eql 1
	      	expect(WhisperReply.last.message).to eql 'Hi!'
	      	expect(WhisperSent.count).to eql 1
	      	expect(RecentActivity.count).to eql 2




	      	post :api_create, :notification_type => '2', :target_id => '3', :intro => "Hi!"
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Cannot send more whispers"

	      	whisper_time = WhisperSent.first.whisper_time
	      	# user_3 -> user_2 reply
	      	token = user_3.generate_token
	      	request.env["X-API-TOKEN"] = token

	      	get :show, :id => 'aaa2'
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whisper_id']).to eql 'aaa2'
	      	expect(JSON.parse(response.body)['data']['intro_message']).to eql "Hi!"
	      	expect(JSON.parse(response.body)['data']['messages_array'].count).to eql 1
	      	expect(JSON.parse(response.body)['data']['messages_array'][0]['speaker_id']).to eql 2
	      	expect(JSON.parse(response.body)['data']['messages_array'][0]['message']).to eql 'Hi!'



	      	post :api_create, :notification_type => '2', :target_id => '2', :intro => "Hello!"
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(WhisperToday.count).to eql 1
	      	expect(WhisperToday.first.message).to eql 'Hi!'
	      	expect(WhisperToday.first.message_b).to eql 'Hello!'
	      	expect(WhisperToday.first.accepted).to eql false
	      	expect(WhisperToday.first.declined).to eql false
	      	expect(WhisperToday.first.paper_owner_id).to eql 2
	      	expect(WhisperReply.count).to eql 2
	      	expect(WhisperReply.last.message).to eql 'Hello!'
	      	expect(WhisperSent.count).to eql 1
	      	expect(WhisperSent.first.whisper_time).to eql whisper_time
	      	expect(RecentActivity.count).to eql 4

	      	post :api_create, :notification_type => '2', :target_id => '2', :intro => "Hi!"
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Cannot send more whispers"


	      	# user_2 -> user_3 reply again
	      	token = user_2.generate_token
	      	request.env["X-API-TOKEN"] = token

	      	get :show, :id => 'aaa2'
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whisper_id']).to eql 'aaa2'
	      	expect(JSON.parse(response.body)['data']['intro_message']).to eql "Hello!"
	      	expect(JSON.parse(response.body)['data']['messages_array'].count).to eql 2
	      	expect(JSON.parse(response.body)['data']['messages_array'][0]['speaker_id']).to eql 3
	      	expect(JSON.parse(response.body)['data']['messages_array'][0]['message']).to eql 'Hello!'

	      	post :api_create, :notification_type => '2', :target_id => '3', :intro => "Hello Again!"
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(WhisperToday.count).to eql 1
	      	expect(WhisperToday.first.message_b).to eql 'Hello!'
	      	expect(WhisperToday.first.message).to eql 'Hello Again!'
	      	expect(WhisperToday.first.accepted).to eql false
	      	expect(WhisperToday.first.declined).to eql false
	      	expect(WhisperToday.first.paper_owner_id).to eql 3
	      	expect(WhisperReply.count).to eql 3
	      	expect(WhisperReply.last.message).to eql 'Hello Again!'
	      	expect(WhisperSent.count).to eql 1
	      	expect(WhisperSent.first.whisper_time).to eql whisper_time
	      	expect(RecentActivity.count).to eql 6

	      	post :api_create, :notification_type => '2', :target_id => '3', :intro => "Hi!"
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Cannot send more whispers"

	      	# accept it
	      	token = user_3.generate_token
	      	request.env["X-API-TOKEN"] = token

	      	get :show, :id => 2
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whisper_id']).to eql 'aaa2'
	      	expect(JSON.parse(response.body)['data']['intro_message']).to eql "Hello Again!"
	      	expect(JSON.parse(response.body)['data']['messages_array'].count).to eql 3
	      	expect(JSON.parse(response.body)['data']['messages_array'][0]['speaker_id']).to eql 2
	      	expect(JSON.parse(response.body)['data']['messages_array'][0]['message']).to eql 'Hello Again!'

	      	post :whisper_request_state, :whisper_id => 'aaa2', :accepted => '0'
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql 'There was an error.'

	      	post :whisper_request_state, :whisper_id => 'aaa', :accepted => '1'
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql 'Permission denied.'

	      	
	      	post :whisper_request_state, :whisper_id => 'aaa2', :accepted => '1'
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(WhisperToday.count).to eql 1
	      	expect(WhisperToday.first.accepted).to eql true
	      	expect(WhisperSent.count).to eql 1
	      	expect(WhisperSent.first.whisper_time).to eql whisper_time
	      	expect(WhisperReply.count).to eql 0	      	
	      	expect(RecentActivity.count).to eql 8
	      	expect(FriendByWhisper.count).to eql 1

	      	WhisperReply.delete_all
	      	WhisperToday.delete_all
	      	WhisperSent.delete_all
	      	FriendByWhisper.delete_all
	      	RecentActivity.delete_all
	      	UserAvatar.delete_all
	      	User.delete_all
	    end

	end
end
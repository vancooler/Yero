require 'spec_helper'

# # API_TEST_BASE_URL = "http://purpleoctopus-staging.herokuapp.com"
# API_TEST_BASE_URL = "http://localhost:3000"

describe 'Enter/Leave Venue' do
  	it "Enter venue" do
  		birthday = (Time.now - 21.years)
		user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)

	    venue_network = VenueNetwork.create!(id:1, name: "V", timezone: "America/Vancouver")
      	venue = Venue.create!(id:1, venue_network: venue_network, name: "AAA")
      	beacon = Beacon.create!(key: "Vancouver_TestVenue_test", venue_id: 1)
	    venue_2 = Venue.create!(id:2, venue_network: venue_network, name: "BBB")
      	beacon_2 = Beacon.create!(key: "Vancouver_TestVenue2_test", venue_id: 2)
	    
      	token = user_2.generate_token

      	post 'api/room/enter', :token => token, :beacon_key => ""
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['message']).to eql "Could not enter."

      	post 'api/room/enter', :token => token, :beacon_key => "Vancouver_1TestVenue_test"
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['message']).to eql "Could not enter."

      	post 'api/room/enter', :token => token, :beacon_key => "Vancouver_TestVenue_test"
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ActiveInVenue.first.beacon.key).to eql "Vancouver_TestVenue_test"
      	expect(ActiveInVenue.count).to eql 1
      	expect(ActiveInVenueNetwork.count).to eql 1

      	post 'api/room/enter', :token => token, :beacon_key => "Vancouver_TestVenue2_test"
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ActiveInVenue.count).to eql 1
      	expect(ActiveInVenue.first.beacon.key).to eql "Vancouver_TestVenue2_test"
      	expect(ActiveInVenueNetwork.count).to eql 1

      	post 'api/room/enter', :token => token, :beacon_key => ["Vancouver_TestVenue2_test", "Vancouver_TestVenue_test"]
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ActiveInVenue.count).to eql 1
      	expect(ActiveInVenue.first.beacon.key).to eql "Vancouver_TestVenue_test"
      	expect(ActiveInVenueNetwork.count).to eql 1

      	post 'api/room/enter', :token => token, :beacon_key => ["Vancouver_TestVenue2_test", "Vancouver_TestVenue_test"]
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ActiveInVenue.count).to eql 1
      	expect(ActiveInVenue.first.beacon.key).to eql "Vancouver_TestVenue_test"
      	expect(ActiveInVenueNetwork.count).to eql 1


      	post 'api/room/leave', :token => token, :beacon_key => ["Vancouver_TestVenue2_test", "Vancouver_TestVenue_test"]
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ActiveInVenue.count).to eql 0
      	expect(ActiveInVenueNetwork.count).to eql 1

      	post 'api/room/leave', :token => token, :beacon_key => ["Vancouver_TestVenue2_test", "Vancouver_TestVenue_test"]
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ActiveInVenue.count).to eql 0
      	expect(ActiveInVenueNetwork.count).to eql 1

      	post 'api/room/enter', :token => token, :beacon_key => ["Vancouver_TestVenue2_test", "Vancouver_TestVenue_test"]
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ActiveInVenue.count).to eql 1
      	expect(ActiveInVenue.first.beacon.key).to eql "Vancouver_TestVenue_test"
      	expect(ActiveInVenueNetwork.count).to eql 1


      	ActiveInVenueNetwork.five_am_cleanup(venue_network)
      	expect(ActiveInVenue.count).to eql 0
      	expect(ActiveInVenueNetwork.count).to eql 0



      	ActiveInVenue.delete_all
      	ActiveInVenueNetwork.delete_all
      	VenueEnteredToday.delete_all
      	Beacon.delete_all
      	Venue.delete_all
      	VenueNetwork.delete_all
      	UserAvatar.delete_all
      	User.delete_all
  	end
end

describe 'Whisper' do
  	describe 'Version 1.3' do
    
  		it "Auth" do
	  		birthday = (Time.now - 21.years)
			user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
		    

	      	post 'api/users'
			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "You must authenticate with a valid token"

	      	token = "user_2.generate_token"
	      	post 'api/users',:token => token
			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "You must authenticate with a valid token"

	      	user = {:id => 200, :exp => (Time.now.to_i + 3600*24) } # expire in 24 hours
	        secret = 'secret'
		    token = JWT.encode(user, secret)
		    post 'api/users',:token => token
			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "You must authenticate with a valid token"

	      	user = { } # expire in 24 hours
	        secret = 'secret'
		    token = JWT.encode(user, secret)
		    post 'api/users',:token => token
			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "You must authenticate with a valid token"

	      	user = { :exp => (Time.now.to_i + 3600*24) } # expire in 24 hours
	        secret = 'secret'
		    token = JWT.encode(user, secret)
		    post 'api/users',:token => token
			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "You must authenticate with a valid token"

	      	user = { :id => 2, :exp => (Time.now.to_i - 3600*24) } # expire in 24 hours
	        secret = 'secret'
		    token = JWT.encode(user, secret)
		    post 'api/users',:token => token
			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Token Expired"


	      	UserAvatar.delete_all
	      	User.delete_all
	  	end

    	it "1.3 sending whispers" do
	    	birthday = (Time.now - 21.years)
			user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
		    
		    user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746133, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_2 = UserAvatar.create!(id: 2, user: user_3, is_active: true, order: 0)
		    
		    user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", email: "test4@yero.co", password: "123456", birthday: (birthday-20.years), gender: 'F', latitude: 49.3247234, longitude: -123.0706173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: false, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_4 = UserAvatar.create!(id: 3, user: user_4, is_active: true, order: 0)

		    gate = GlobalVariable.create!(name: "min_ppl_size", value: "2")
	      	token = user_2.generate_token

	      	# user_2 -> user_3 initial whisper
	      	expect(WhisperNotification.collect_whispers(user_2).count).to eql 0

	      	post 'api/users', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1
	      	expect(JSON.parse(response.body)['users'][0]['id']).to eql 3
	      	expect(JSON.parse(response.body)['users'][0]['whisper_sent']).to eql false
	      	expect(JSON.parse(response.body)['users'][0]['actions'].count).to eql 1

	      	post "api/whisper/create", :notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token
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

	      	post "api/whisper/create", :notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Cannot send more whispers"

	      	post 'api/users', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1
	      	expect(JSON.parse(response.body)['users'][0]['actions'].count).to eql 0


	      	whisper_time = WhisperSent.first.whisper_time

	      	# user_3 -> user_2 reply
	      	token = user_3.generate_token

	      	post 'api/users', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1
	      	expect(JSON.parse(response.body)['users'][0]['actions'].count).to eql 3

	      	get 'api/whispers/aaa2?token='+token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whisper_id']).to eql 'aaa2'
	      	expect(JSON.parse(response.body)['data']['intro_message']).to eql "Hi!"
	      	expect(JSON.parse(response.body)['data']['messages_array'].count).to eql 1
	      	expect(JSON.parse(response.body)['data']['messages_array'][0]['speaker_id']).to eql 2
	      	expect(JSON.parse(response.body)['data']['messages_array'][0]['message']).to eql 'Hi!'

	      	post 'api/whispers', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 1
	      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'].count).to eql 1
	      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'][0]['message']).to eql 'Hi!'
	      	expect(JSON.parse(response.body)['data']['whispers'][0]['actions'].count).to eql 3
	      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 1
	      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0


	      	post "api/whisper/create", :notification_type => '2', :target_id => '2', :intro => "Hello!", :token => token
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

	      	post "api/whisper/create", :notification_type => '2', :target_id => '2', :intro => "Hi!", :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Cannot send more whispers"

	      	post 'api/whispers', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 1
	      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'].count).to eql 2
	      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'][0]['message']).to eql 'Hello!'
	      	expect(JSON.parse(response.body)['data']['whispers'][0]['actions'].count).to eql 2
	      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 0
	      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

	      	post 'api/users', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1
	      	expect(JSON.parse(response.body)['users'][0]['actions'].count).to eql 2


	      	# user_2 -> user_3 reply again
	      	token = user_2.generate_token

	      	post 'api/users', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1
	      	expect(JSON.parse(response.body)['users'][0]['actions'].count).to eql 2


	      	get 'api/whispers/aaa2?token='+token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whisper_id']).to eql 'aaa2'
	      	expect(JSON.parse(response.body)['data']['intro_message']).to eql "Hello!"
	      	expect(JSON.parse(response.body)['data']['messages_array'].count).to eql 2
	      	expect(JSON.parse(response.body)['data']['messages_array'][0]['speaker_id']).to eql 3
	      	expect(JSON.parse(response.body)['data']['messages_array'][0]['message']).to eql 'Hello!'

			post 'api/whispers', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 1
	      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'].count).to eql 2
	      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'][0]['message']).to eql 'Hello!'
	      	expect(JSON.parse(response.body)['data']['whispers'][0]['actions'].count).to eql 2
	      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 1
	      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

	      	post "api/whisper/create", :notification_type => '2', :target_id => '3', :intro => "Hello Again!", :token => token
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

	      	post "api/whisper/create", :notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Cannot send more whispers"

	      	post 'api/whispers', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 0
	      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 0
	      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

	      	post 'api/users', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1
	      	expect(JSON.parse(response.body)['users'][0]['actions'].count).to eql 0


	      	# accept it
	      	token = user_3.generate_token

	      	get 'api/whispers/2?token='+token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whisper_id']).to eql 'aaa2'
	      	expect(JSON.parse(response.body)['data']['intro_message']).to eql "Hello Again!"
	      	expect(JSON.parse(response.body)['data']['messages_array'].count).to eql 3
	      	expect(JSON.parse(response.body)['data']['messages_array'][0]['speaker_id']).to eql 2
	      	expect(JSON.parse(response.body)['data']['messages_array'][0]['message']).to eql 'Hello Again!'

	      	post 'api/whispers', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 1
	      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'].count).to eql 3
	      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'][0]['message']).to eql 'Hello Again!'
	      	expect(JSON.parse(response.body)['data']['whispers'][0]['actions'].count).to eql 3
	      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 1
	      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

	      	post 'api/users', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1
	      	expect(JSON.parse(response.body)['users'][0]['actions'].count).to eql 3
	      	expect(JSON.parse(response.body)['users'][0]['messages_array'].count).to eql 3
	      	expect(JSON.parse(response.body)['users'][0]['whisper_id']).to eql 'aaa2'



	      	post 'api/whisper/whisper_request_state', :whisper_id => 'aaa2', :accepted => '0', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql 'There was an error.'

	      	post 'api/whisper/whisper_request_state', :whisper_id => 'aaa', :accepted => '1', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql 'Cannot find the whisper.'

	      	
	      	post 'api/whisper/whisper_request_state', :whisper_id => 'aaa2', :accepted => '1', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(WhisperToday.count).to eql 0
	      	expect(WhisperSent.count).to eql 1
	      	expect(WhisperSent.first.whisper_time).to eql whisper_time
	      	expect(WhisperReply.count).to eql 0	      	
	      	expect(RecentActivity.count).to eql 8
	      	expect(FriendByWhisper.count).to eql 1

	      	post 'api/users', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1
	      	expect(JSON.parse(response.body)['users'][0]['actions'].count).to eql 1

	      	token = user_2.generate_token

	      	post 'api/users', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1
	      	expect(JSON.parse(response.body)['users'][0]['actions'].count).to eql 1
	      	expect(JSON.parse(response.body)['users'][0]['friend']).to eql true

	      	get 'api/whispers/3?token='+token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['data']['code']).to eql 404
	      	expect(JSON.parse(response.body)['data']['message']).to eql 'Sorry, cannot find the whisper'


	      	gate.delete
	      	WhisperReply.delete_all
	      	WhisperToday.delete_all
	      	WhisperSent.delete_all
	      	FriendByWhisper.delete_all
	      	RecentActivity.delete_all
	      	UserAvatar.delete_all
	      	User.delete_all
	    end

	    it "1.3 delete whisper" do
	    	birthday = (Time.now - 21.years)
			user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
		    
		    user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746133, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_2 = UserAvatar.create!(id: 2, user: user_3, is_active: true, order: 0)
		    
		    user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", email: "test4@yero.co", password: "123456", birthday: (birthday-20.years), gender: 'F', latitude: 49.3247234, longitude: -123.0706173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: false, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_4 = UserAvatar.create!(id: 3, user: user_4, is_active: true, order: 0)

		    gate = GlobalVariable.create!(name: "min_ppl_size", value: "2")
	      	token = user_2.generate_token

	      	# user_2 -> user_3 initial whisper
	      	expect(WhisperNotification.collect_whispers(user_2).count).to eql 0

	      	post 'api/users', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1
	      	expect(JSON.parse(response.body)['users'][0]['id']).to eql 3
	      	expect(JSON.parse(response.body)['users'][0]['whisper_sent']).to eql false
	      	expect(JSON.parse(response.body)['users'][0]['actions'].count).to eql 1

	      	post "api/whisper/create", :notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token
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

	      	post "api/whisper/create", :notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Cannot send more whispers"

	      	post 'api/users', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1
	      	expect(JSON.parse(response.body)['users'][0]['actions'].count).to eql 0


	      	whisper_time = WhisperSent.first.whisper_time

	      	# user_3 -> user_2 reply
	      	token = user_3.generate_token

	      	post 'api/users', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1
	      	expect(JSON.parse(response.body)['users'][0]['actions'].count).to eql 3

	      	get 'api/whispers/aaa2?token='+token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whisper_id']).to eql 'aaa2'
	      	expect(JSON.parse(response.body)['data']['intro_message']).to eql "Hi!"
	      	expect(JSON.parse(response.body)['data']['actions'].count).to eql 3
	      	expect(JSON.parse(response.body)['data']['messages_array'].count).to eql 1
	      	expect(JSON.parse(response.body)['data']['messages_array'][0]['speaker_id']).to eql 2
	      	expect(JSON.parse(response.body)['data']['messages_array'][0]['message']).to eql 'Hi!'

	      	post 'api/whispers', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 1
	      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'].count).to eql 1
	      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'][0]['message']).to eql 'Hi!'
	      	expect(JSON.parse(response.body)['data']['whispers'][0]['actions'].count).to eql 3
	      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 1
	      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

	      	post 'api/whisper/whisper_request_state', :whisper_id => 'aaa2', :declined => '1', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true


	      	expect(WhisperToday.count).to eql 0
	      	expect(WhisperReply.count).to eql 0
    
    		ws = WhisperSent.last
    		ws.whisper_time = Time.now - 23.hours
    		ws.save!

	      	post 'api/users', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1
	      	expect(JSON.parse(response.body)['users'][0]['actions'].count).to eql 1

	      	post 'api/whispers', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 0
	      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 0
	      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

	      	token = user_2.generate_token
	      	post "api/whisper/create", :notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token
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
	      	expect(RecentActivity.count).to eql 4

	      	token = user_3.generate_token
	      	post 'api/whisper/decline_whisper_requests', :token => token, :array => ['aaa2']
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true

	      	post 'api/users', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1
	      	expect(JSON.parse(response.body)['users'][0]['actions'].count).to eql 1
	      	expect(WhisperToday.count).to eql 0
	      	expect(WhisperReply.count).to eql 0

	      	gate.delete
	      	WhisperReply.delete_all
	      	WhisperToday.delete_all
	      	WhisperSent.delete_all
	      	FriendByWhisper.delete_all
	      	RecentActivity.delete_all
	      	UserAvatar.delete_all
	      	User.delete_all
	    end


	    it "1.3 expire whisper" do
	    	birthday = (Time.now - 21.years)
			user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
		    
		    user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746133, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_2 = UserAvatar.create!(id: 2, user: user_3, is_active: true, order: 0)
		    
		    user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", email: "test4@yero.co", password: "123456", birthday: (birthday-20.years), gender: 'F', latitude: 49.3247234, longitude: -123.0706173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: false, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_4 = UserAvatar.create!(id: 3, user: user_4, is_active: true, order: 0)

	      	token = user_2.generate_token

	      	post "api/whisper/create", :notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token
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

	      	whisper = WhisperToday.first
	      	whisper.created_at = Time.now - 12.hours - 1.second
	      	whisper.updated_at = Time.now - 12.hours - 1.second
	      	whisper.save!

	      	WhisperToday.expire
	      	expect(WhisperToday.count).to eql 0
	      	expect(WhisperReply.count).to eql 0

	      	post "api/whisper/create", :notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Cannot send more whispers"

	      	WhisperSent.delete_all

	      	post "api/whisper/create", :notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true

	      	# user_3 -> user_2 reply
	      	token = user_3.generate_token
	      	post "api/whisper/create", :notification_type => '2', :target_id => '2', :intro => "Hello!", :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true

	      	whisper = WhisperToday.first
	      	whisper.created_at = Time.now - 12.hours - 1.second
	      	whisper.updated_at = Time.now - 12.hours - 1.second
	      	whisper.save!

	      	WhisperToday.expire
	      	expect(WhisperToday.count).to eql 1
	      	expect(WhisperReply.count).to eql 2


	      	# user_3 -> user_2 reply
	      	token = user_2.generate_token
	      	post "api/whisper/create", :notification_type => '2', :target_id => '3', :intro => "Hello Again!", :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true

	      	whisper = WhisperToday.first
	      	whisper.created_at = Time.now - 12.hours - 1.second
	      	whisper.updated_at = Time.now - 12.hours - 1.second
	      	whisper.save!

	      	WhisperToday.expire
	      	expect(WhisperToday.count).to eql 1
	      	expect(WhisperReply.count).to eql 3

	      	WhisperReply.delete_all
	      	WhisperToday.delete_all
	      	WhisperSent.delete_all
	      	FriendByWhisper.delete_all
	      	RecentActivity.delete_all
	      	UserAvatar.delete_all
	      	User.delete_all
		end



		it "1.3 user A delete whisper" do
	    	birthday = (Time.now - 21.years)
			user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
		    
		    user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746133, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_2 = UserAvatar.create!(id: 2, user: user_3, is_active: true, order: 0)
		    
		    user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", email: "test4@yero.co", password: "123456", birthday: (birthday-20.years), gender: 'F', latitude: 49.3247234, longitude: -123.0706173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: false, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_4 = UserAvatar.create!(id: 3, user: user_4, is_active: true, order: 0)

		    token = user_2.generate_token

	      	post "api/whisper/create", :notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token
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

	      	token = user_3.generate_token

	      	post "api/whisper/create", :notification_type => '2', :target_id => '2', :intro => "Hi!", :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(WhisperToday.count).to eql 1
	      	expect(WhisperToday.first.message).to eql 'Hi!'
	      	expect(WhisperToday.first.message_b).to eql 'Hi!'
	      	expect(WhisperToday.first.accepted).to eql false
	      	expect(WhisperToday.first.declined).to eql false
	      	expect(WhisperToday.first.paper_owner_id).to eql 2
	      	expect(WhisperReply.count).to eql 2
	      	expect(WhisperReply.last.message).to eql 'Hi!'
	      	expect(WhisperSent.count).to eql 1
	      	expect(RecentActivity.count).to eql 4

	      	token = user_2.generate_token
	      	post 'api/whisper/whisper_request_state', :whisper_id => 'aaa2', :declined => '1', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true


	      	expect(WhisperToday.count).to eql 0
	      	expect(WhisperReply.count).to eql 0
    
	      	token = user_3.generate_token
	      	post 'api/whisper/whisper_request_state', :whisper_id => 'aaa2', :declined => '1', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Cannot find the whisper."



		    WhisperToday.delete_all
		    WhisperSent.delete_all
		    WhisperReply.delete_all
		    RecentActivity.delete_all
		    UserAvatar.delete_all
		    User.delete_all
		end

		# it "1.3 admin create test whisper" do
	 #    	birthday = (Time.now - 21.years)
		# 	user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		#     ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
		    
		#     user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746133, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		#     ua_2 = UserAvatar.create!(id: 2, user: user_3, is_active: true, order: 0)
		    
		#     user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", email: "test4@yero.co", password: "123456", birthday: (birthday-20.years), gender: 'F', latitude: 49.3247234, longitude: -123.0706173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: false, current_city: "Vancouver", timezone_name: "America/Vancouver")
		#     ua_4 = UserAvatar.create!(id: 3, user: user_4, is_active: true, order: 0)

		#     post 'send-test-whisper', :origin_user_id => 2, :target_user_id => 3, :message => "HHHHH"
		#     expect(assigns(:message)).to eql "Whisper sent!"
		#     expect(WhisperToday.count).to eql 1
		#     expect(WhisperSent.count).to eql 1
		#     expect(RecentActivity.count).to eql 2
		#     expect(WhisperReply.count).to eql 1

		#     post 'send-test-whisper', :origin_user_id => 6, :target_user_id => 3, :message => "HHHHH"
		#     expect(assigns(:message)).to eql "Cannot find origin user!"

		#     post 'send-test-whisper', :origin_user_id => 6, :target_user_id => 33, :message => "HHHHH"
		#     expect(assigns(:message)).to eql "Cannot find target user!"

		#     WhisperToday.delete_all
		#     WhisperSent.delete_all
		#     WhisperReply.delete_all
		#     RecentActivity.delete_all
		#     UserAvatar.delete_all
		#     User.delete_all
		# end

  	end


end


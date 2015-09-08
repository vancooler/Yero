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

	      	get 'api/whispers/aaa2asdf?token='+token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['data']['code']).to eql 404
	      	expect(JSON.parse(response.body)['data']['message']).to eql "Sorry, cannot find the whisper"


	      	token = user_4.generate_token
	      	get 'api/whispers/aaa2?token='+token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['data']['code']).to eql 403
	      	expect(JSON.parse(response.body)['data']['message']).to eql "Sorry, you don't have access to it"

	      	# Block
	      	BlockUser.create!(origin_user_id: 2, target_user_id: 3)
	      	token = user_3.generate_token
	      	get 'api/whispers/aaa2?token='+token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['data']['code']).to eql 403
	      	expect(JSON.parse(response.body)['data']['message']).to eql "Sorry, you don't have access to it"

	      	BlockUser.delete_all
	      	# No photo
	      	ua.delete
		    
	      	token = user_3.generate_token

	      	get 'api/whispers/aaa2?token='+token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['data']['code']).to eql 403
	      	expect(JSON.parse(response.body)['data']['message']).to eql "Sorry, you don't have access to it"


	      	ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)

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
    		ws.whisper_time = Time.now - 53.hours
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

	      	get 'api/activities?per_page=48&page=0&token='+ token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data'].count).to eql 2


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
	      	whisper.created_at = Time.now - 24.hours - 1.second
	      	whisper.updated_at = Time.now - 24.hours - 1.second
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





  	describe "User controller" do

		it "Signup" do
			birthday = (Time.now - 21.years)
			user_2 = User.create!(id:1, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    # No email 
		    post 'api/users/check-email', :email => ''
			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "No email address"
	      	# Email exist
	      	post 'api/users/check-email', :email => 'test2@yero.co'
			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Email address exists"
      		# Good
      		post 'api/users/check-email', :email => 'test3@yero.co'
			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql true

			# required info missing
			post 'api/users/signup_no_avatar', :email => '', :password => '12', :birthday => 'asf', :first_name => 'sdf', :gender => 'F'
 			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Required fields cannot be blank"

	      	post 'api/users/signup_no_avatar', :email => 'sdf@sdf.cs', :password => '', :birthday => 'asf', :first_name => 'sdf', :gender => 'F'
 			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Required fields cannot be blank"

	      	post 'api/users/signup_no_avatar', :email => 'sdf@sdf.cs', :password => '12', :birthday => '', :first_name => 'sdf', :gender => 'F'
 			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Required fields cannot be blank"

	      	post 'api/users/signup_no_avatar', :email => 'sdf@sf.cs', :password => '12', :birthday => 'asf', :first_name => '', :gender => 'F'
 			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Required fields cannot be blank"

	      	post 'api/users/signup_no_avatar', :email => 'sdf@sf.cs', :password => '12', :birthday => 'asf', :first_name => 'sdfsf', :gender => ''
 			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Required fields cannot be blank"

      		post 'api/users/signup_no_avatar', :email => 'test2@yero.co', :password => '12', :birthday => 'asf', :first_name => 'sdfsf', :gender => 'F'
      		expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "This email has already been taken."

	      	post 'api/users/signup_no_avatar', :email => 'test2s@yero.co', :password => '12', :birthday => 'asf', :first_name => 'sdfsf', :gender => 'F'
      		expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']["birthday"]).to eql ["can't be blank"]

	      	post 'api/users/signup_no_avatar', :email => 'test2yero.co', :password => '12', :birthday => 'May 23, 1990', :first_name => 'sdfsf', :gender => 'F'
      		expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']['email']).to eql ["is invalid"]

	      	post 'api/users/signup_no_avatar', :email => 'test3@yero.co', :password => '123456', :birthday => 'May 23, 1990', :first_name => 'Test', :gender => 'M', :instagram_id => 'ds', :snapchat_id => 'sfd', :wechat_id => 'sdf', :line_id => 'line_id'
      		expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql User.last.id

	      	post 'api/users/signup_no_avatar', :email => 'test4 @yero.co', :password => '123456', :birthday => 'May 23, 1990', :first_name => 'Te st4', :gender => 'M ', :instagram_id => 'd s', :snapchat_id => 'sf d', :wechat_id => 's df', :line_id => 'lin e_id'
      		expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql User.last.id
	      	expect(JSON.parse(response.body)['data']['instagram_id']).to eql 'ds'
	      	expect(JSON.parse(response.body)['data']['wechat_id']).to eql 'sdf'
	      	expect(JSON.parse(response.body)['data']['line_id']).to eql 'line_id'
	      	expect(JSON.parse(response.body)['data']['snapchat_id']).to eql 'sfd'

	      	# forget password
			post 'api/users/forgot_password', :email => 'test5@yero.co'
			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql 'The email you have used is not valid.'

	      	post 'api/users/forgot_password', :email => 'test3@yero.co'
			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql true

			
			post 'api/users/login', :email => "test3@yero.co", :password => "123456"
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['email']).to eql 'test3@yero.co'

	      	User.destroy_all
      
		end

	    it "Login" do
	    	birthday = (Time.now - 21.years)
			user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    post 'api/users/login', :email => "test2@yero.co", :password => ""
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Login information missing."

	      	post 'api/users/login', :email => "test2@yero.dco", :password => "sdf"
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Email address not found"

	      	post 'api/users/login', :email => "test2@yero.co", :password => "wersfd"
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Your email or password is incorrect"

	      	post 'api/users/login', :email => "test2@yero.co", :password => "123456"
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql 2

	      	token = JSON.parse(response.body)['data']['token']


	      	user_2.destroy
	    end


	    it "Show" do 
	    	birthday = (Time.now - 21.years)
			user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
		    post 'api/users/login', {email: 'test2@yero.co', password: '123456'}
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql 2

	      	token = JSON.parse(response.body)['data']['token']
	    	post 'api/user/show', :token => token
	    	expect(response.status).to eql 200
	    	expect(JSON.parse(response.body)['message']).to eql nil
	    	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql 2

	      	ua.destroy
	    	user_2.destroy
	    end


	    it "Index" do 
	    	birthday = (Time.now - 21.years)
			user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: false, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
		    
		    user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746133, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_2 = UserAvatar.create!(id: 2, user: user_3, is_active: true, order: 0)
		    
		    user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", email: "test4@yero.co", password: "123456", birthday: (birthday-20.years), gender: 'F', latitude: 49.3247234, longitude: -123.0706173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_4 = UserAvatar.create!(id: 3, user: user_4, is_active: true, order: 0)
		    
		    venue_network = VenueNetwork.create!(id:1, name: "V")
	    	venue = Venue.create!(id:1, venue_network: venue_network, name: "AAA")
	    	venue_2 = Venue.create!(id:2, venue_network: venue_network, name: "BBB")
	      	active_in_venue = ActiveInVenue.create!(user_id: 2, venue_id:1)
	      	active_in_venue_2 = ActiveInVenue.create!(user_id: 3, venue_id:1)

		    post 'api/users/login', {email: 'test2@yero.co', password: '123456'}
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql 2

	      	token = JSON.parse(response.body)['data']['token']

	    	post 'api/users', :token => token
	    	expect(response.status).to eql 200
	    	expect(JSON.parse(response.body)['message']).to eql nil
	    	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['percentage']).to eql 75

	      	gate = GlobalVariable.create!(name: "min_ppl_size", value: "2")
	      	post 'api/users', :token => token
	    	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['message']).to eql nil
	    	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 2

	      	post 'api/users', :min_age => 25, :max_age => 27, :token => token
	    	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['message']).to eql nil
	    	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 0

	      	post 'api/users', :max_distance => 2, :token => token
	    	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['message']).to eql nil
	    	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1

	      	post 'api/users', :everyone => false, :token => token
	    	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['message']).to eql nil
	    	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1
	      	expect(JSON.parse(response.body)['users'][0]['same_venue_badge']).to eql true
	      	expect(JSON.parse(response.body)['users'][0]['different_venue_badge']).to eql false

	      	active_in_venue_2.venue_id = 2
	      	active_in_venue_2.save!
	      	post 'api/users', :everyone => false, :token => token
	    	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['message']).to eql nil
	    	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1
	      	expect(JSON.parse(response.body)['users'][0]['same_venue_badge']).to eql false	      	
	      	expect(JSON.parse(response.body)['users'][0]['different_venue_badge']).to eql true

	      	post 'api/users/block-user', :user_id => 3, :token => token
	      	expect(response.status).to eql 200
	    	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']).to eql [3]

	      	post 'api/users/block-user', :user_id => 30, :token => token
	      	expect(response.status).to eql 200
	    	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Sorry, this user doesn't exist"

	      	post 'api/users/block-user', :token => token
	      	expect(response.status).to eql 200
	    	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Sorry, user_id required"

	      	post 'api/users', :token => token
	    	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['message']).to eql nil
	    	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1

	      	ua.is_active = false
	      	ua.save!
	      	post 'api/users', :max_distance => 2, :token => token
	    	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['message']).to eql "No photos"
	    	expect(JSON.parse(response.body)['success']).to eql false

	    	venue_network.delete
	    	Venue.delete_all
	    	ActiveInVenue.delete_all
	      	gate.delete
	      	UserAvatar.delete_all
	    	User.delete_all
	    end


	    it "Whispers" do 
	    	birthday = (Time.now - 21.years)
			user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: false, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
		    
		    user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746133, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_2 = UserAvatar.create!(id: 2, user: user_3, is_active: true, order: 0)
		    
		    user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", email: "test4@yero.co", password: "123456", birthday: (birthday-20.years), gender: 'F', latitude: 49.3247234, longitude: -123.0706173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_4 = UserAvatar.create!(id: 3, user: user_4, is_active: true, order: 0)

		    post 'api/users/login', {email: 'test2@yero.co', password: '123456'}
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql 2

	      	token = JSON.parse(response.body)['data']['token']

	      	friend = FriendByWhisper.create!(target_user_id: 3, origin_user_id: 2, friend_time: Time.now, viewed: false)
	      	post 'api/whispers', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 0
	      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 1
	      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 1

	      	post 'api/whispers', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 0
	      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 0
	      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

	      	friend.delete
	      	whisper = WhisperToday.create!(paper_owner_id: 2, target_user_id: 2, origin_user_id: 4, whisper_type: '2', viewed: false)
	      	post 'api/whispers', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 1
	      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 1
	      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

	      	post 'api/whispers', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 1
	      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 0
	      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

	      	whisper = WhisperToday.create!(paper_owner_id: 2, target_user_id: 2, origin_user_id: 3, whisper_type: '2', viewed: false)
	      	friend = FriendByWhisper.create!(target_user_id: 3, origin_user_id: 2, friend_time: Time.now, viewed: false)

	      	post 'api/whispers', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 2
	      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 2
	      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 1

	      	post 'api/whispers', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 2
	      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 0
	      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

	      	post 'api/friends', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['friends'].count).to eql 1
	      	expect(JSON.parse(response.body)['data']['friends'][0]['actions']).to eql ['chat']

	    	friend.delete
	    	whisper.delete
	    	UserAvatar.delete_all
	    	User.delete_all
	    end


	    it "Report" do 
	    	birthday = (Time.now - 21.years)
			user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: false, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
		    
		    user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746133, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_2 = UserAvatar.create!(id: 2, user: user_3, is_active: true, order: 0)
		    
		    user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", email: "test4@yero.co", password: "123456", birthday: (birthday-20.years), gender: 'F', latitude: 49.3247234, longitude: -123.0706173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_4 = UserAvatar.create!(id: 3, user: user_4, is_active: true, order: 0)

		    post 'api/users/login', {email: 'test2@yero.co', password: '123456'}
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql 2

	      	token = JSON.parse(response.body)['data']['token']

	      	ReportType.create!(:id => 1, :report_type_name => "AAA")
	      	ReportType.create!(:id => 2, :report_type_name => "AwA")
	      	
	      	post 'api/report', :user_id => 3, :type_id => 1, :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(ReportUserHistory.count).to eql 1

	      	post 'api/report', :user_id => 3, :type_id => 1, :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(ReportUserHistory.count).to eql 2

	      	post 'api/report', :user_id => 3, :type_id => 2, :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(ReportUserHistory.count).to eql 3

	      	post 'api/report', :user_id => 9, :type_id => 20, :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']).to eql false

	      	expect(ReportUserHistory.all.map(&:frequency)).to eql [2, 2, 1]

	      	ReportUserHistory.delete_all
	      	ReportType.delete_all
	      	UserAvatar.delete_all
	    	User.delete_all
	    end

	    it "Update chat account" do 
	    	birthday = (Time.now - 21.years)
			user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: false, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
		    uaa = UserAvatar.create!(id: 10, user: user_2, is_active: true, order: 1)
		    uaaa = UserAvatar.create!(id: 11, user: user_2, is_active: true, order: 2)
		    
		    user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746133, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_2 = UserAvatar.create!(id: 2, user: user_3, is_active: true, order: 0)
		    
		    user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", email: "test4@yero.co", password: "123456", birthday: (birthday-20.years), gender: 'F', latitude: 49.3247234, longitude: -123.0706173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_4 = UserAvatar.create!(id: 3, user: user_4, is_active: true, order: 0)

		    post 'api/users/login', {email: 'test2@yero.co', password: '123456'}
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql 2

	      	token = JSON.parse(response.body)['data']['token']


	      	post 'api/users/update_chat_accounts', :instagram_id => '0 0', :snapchat_id => 'a a', :wechat_id => 'b b', :line_id => 'c c', :instagram_token => 'd d', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['instagram_id']).to eql '00'
	      	expect(JSON.parse(response.body)['data']['snapchat_id']).to eql 'aa'
	      	expect(JSON.parse(response.body)['data']['wechat_id']).to eql 'bb'
	      	expect(JSON.parse(response.body)['data']['line_id']).to eql 'cc'
	      	expect(JSON.parse(response.body)['data']['instagram_token']).to eql 'dd'

	      	post 'api/users/update_chat_accounts', :instagram_id => '10', :snapchat_id => '', :wechat_id => '', :line_id => '', :instagram_token => 'dd', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql 'You must have at least one chatting account'
	      	expect(User.find(2).instagram_id).to eql '00'
	      	expect(User.find(2).snapchat_id).to eql 'aa'
	      	expect(User.find(2).wechat_id).to eql 'bb'
	      	expect(User.find(2).line_id).to eql 'cc'
	      	expect(User.find(2).instagram_token).to eql 'dd'


	      	put 'api/user/update_profile', :avatars => [10, 11, 1], :introduction_1 => 'hello!saDFASFSADFWer!@#$%^&*#', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['introduction_1']).to eql 'hello!saDFASFSADFWer!@#$%^&*#'
	      	expect(JSON.parse(response.body)['data']['avatars'][0]['avatar_id']).to eql 10
	      	expect(JSON.parse(response.body)['data']['avatars'][1]['avatar_id']).to eql 11
	      	expect(JSON.parse(response.body)['data']['avatars'][2]['avatar_id']).to eql 1
	      	
	      	put 'api/user/update_profile', :avatars => [1, 11, 10], :introduction_1 => 'hello!saDFASFSADFWer!@#$%^&*#', :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['introduction_1']).to eql 'hello!saDFASFSADFWer!@#$%^&*#'
	      	expect(JSON.parse(response.body)['data']['avatars'][0]['avatar_id']).to eql 1
	      	expect(JSON.parse(response.body)['data']['avatars'][1]['avatar_id']).to eql 11
	      	expect(JSON.parse(response.body)['data']['avatars'][2]['avatar_id']).to eql 10
	      	
	      	post 'api/users/update', :exclusive => true, :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['exclusive']).to eql true
	      	expect(User.find(2).exclusive).to eql true
	      	
	      	NotificationPreference.create!(name: "Network online")
			NotificationPreference.create!(name: "Enter venue network")
			NotificationPreference.create!(name: "Leave venue network")
	      	post 'api/users/notification-preference', :network_online => false, :enter_venue_network => false, :leave_venue_network => true, :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']).to eql true
	      	expect(UserNotificationPreference.where(:user_id => 2).count).to eql 3

	      	post 'api/users/notification-preference', :network_online => true, :enter_venue_network => true, :leave_venue_network => false, :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']).to eql true
	      	expect(UserNotificationPreference.where(:user_id => 2).count).to eql 0

	      	NotificationPreference.delete_all
			UserNotificationPreference.delete_all	      	
	      	UserAvatar.delete_all
	    	User.delete_all
		end	    

		it "set global variable" do
			get 'api/set-variable', :variable => '', :value => 'd'
			expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql 'Invalid params'
			get 'api/set-variable', :variable => 'test', :value => '1'
			expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(GlobalVariable.find_by_name('test').value).to eql '1'

	      	get 'api/set-variable', :variable => 'test', :value => '2'
			expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(GlobalVariable.find_by_name('test').value).to eql '2'

	      	GlobalVariable.delete_all
		end

		it "send reset email" do
			birthday = (Time.now - 21.years)
			user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: false, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
		    uaa = UserAvatar.create!(id: 10, user: user_2, is_active: true, order: 1)
		    uaaa = UserAvatar.create!(id: 11, user: user_2, is_active: true, order: 2)
		    
		    user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746133, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_2 = UserAvatar.create!(id: 2, user: user_3, is_active: true, order: 0)
		    
		    user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", email: "test4@yero.co", password: "123456", birthday: (birthday-20.years), gender: 'F', latitude: 49.3247234, longitude: -123.0706173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    ua_4 = UserAvatar.create!(id: 3, user: user_4, is_active: true, order: 0)

		    post 'api/users/login', {email: 'test2@yero.co', password: '123456'}
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql 2

	      	token = JSON.parse(response.body)['data']['token']
	      	post 'api/users/generate_reset_email_verify', :new_email => "", :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql 'New email cannot be blank'

	      	post 'api/users/generate_reset_email_verify', :new_email => "test3@yero.co", :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql 'There is already an account with this email address.'

	      	post 'api/users/generate_reset_email_verify', :new_email => "test30@yero.co", :token => token
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']).to eql true

	      	UserAvatar.delete_all
	      	User.delete_all
		end
	end


end


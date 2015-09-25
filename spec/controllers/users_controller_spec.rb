require 'spec_helper'

describe UsersController do
	# before do
	# 	birthday = (Time.now - 21.years)
	# 	user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	#     post :login, :email => "test2@yero.co", :password => "123456"
	# end


	describe "User controller" do

		it "Signup" do
			birthday = (Time.now - 21.years)
			user_2 = User.create!(id:1, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    # No email 
		    post :check_email, :email => ''
			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "No email address"
	      	# Email exist
	      	post :check_email, :email => 'test2@yero.co'
			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Email address exists"
      		# Good
      		post :check_email, :email => 'test3@yero.co'
			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql true

			# required info missing
			post :sign_up_without_avatar, :email => '', :password => '12', :birthday => 'asf', :first_name => 'sdf', :gender => 'F'
 			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Required fields cannot be blank"

	      	post :sign_up_without_avatar, :email => 'sdf@sdf.cs', :password => '', :birthday => 'asf', :first_name => 'sdf', :gender => 'F'
 			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Required fields cannot be blank"

	      	post :sign_up_without_avatar, :email => 'sdf@sdf.cs', :password => '12', :birthday => '', :first_name => 'sdf', :gender => 'F'
 			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Required fields cannot be blank"

	      	post :sign_up_without_avatar, :email => 'sdf@sf.cs', :password => '12', :birthday => 'asf', :first_name => '', :gender => 'F'
 			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Required fields cannot be blank"

	      	post :sign_up_without_avatar, :email => 'sdf@sf.cs', :password => '12', :birthday => 'asf', :first_name => 'sdfsf', :gender => ''
 			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Required fields cannot be blank"

      		post :sign_up_without_avatar, :email => 'test2@yero.co', :password => '12', :birthday => 'asf', :first_name => 'sdfsf', :gender => 'F'
      		expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "This email has already been taken."

	      	post :sign_up_without_avatar, :email => 'test2s@yero.co', :password => '12', :birthday => 'asf', :first_name => 'sdfsf', :gender => 'F'
      		expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']["birthday"]).to eql ["can't be blank"]

	      	post :sign_up_without_avatar, :email => 'test2yero.co', :password => '12', :birthday => 'May 23, 1990', :first_name => 'sdfsf', :gender => 'F'
      		expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']['email']).to eql ["is invalid"]

	      	post :sign_up_without_avatar, :email => 'test3@yero.co', :password => '123456', :birthday => 'May 23, 1990', :first_name => 'Test', :gender => 'M', :instagram_id => 'ds', :snapchat_id => 'sfd', :wechat_id => 'sdf', :line_id => 'line_id'
      		expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql User.last.id

	      	post :sign_up_without_avatar, :email => 'test4 @yero.co', :password => '123456', :birthday => 'May 23, 1990', :first_name => 'Te st4', :gender => 'M ', :instagram_id => 'd s', :snapchat_id => 'sf d', :wechat_id => 's df', :line_id => 'lin e_id'
      		expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql User.last.id
	      	expect(JSON.parse(response.body)['data']['instagram_id']).to eql 'ds'
	      	expect(JSON.parse(response.body)['data']['wechat_id']).to eql 'sdf'
	      	expect(JSON.parse(response.body)['data']['line_id']).to eql 'line_id'
	      	expect(JSON.parse(response.body)['data']['snapchat_id']).to eql 'sfd'

	      	# forget password
			post :forgot_password, :email => 'test5@yero.co'
			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql 'The email you have used is not valid.'

	      	post :forgot_password, :email => 'test3@yero.co'
			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql true

			password_reset_token = User.find_by_email('test3@yero.co').password_reset_token
			post :password_reset, :password_reset_token => '1', :user => {:password_reset_token => password_reset_token, :email => '', :password => '', :password_confirmation => ''}
			expect(response.status).to eql 200
			expect(assigns(:error)).to eql ['Email given does not match email from password recovery.', 'Email cannot be blank.', 'Password cannot be empty.', 'Password confirmation cannot be empty.', 'Your new password must be at least 6 characters.']

			post :password_reset, :password_reset_token => '1', :user => {:password_reset_token => password_reset_token, :email => 'fgdfasdf', :password => '123456', :password_confirmation => '123457'}
			expect(response.status).to eql 200
			expect(assigns(:error)).to eql ['Email given does not match email from password recovery.', 'Your new passwords do not match.', 'Please enter a valid email address.']

			post :password_reset, :password_reset_token => '1', :user => {:password_reset_token => password_reset_token, :email => 'test3@yero.co', :password => '11111111', :password_confirmation => '11111111'}
			expect(response.status).to eql 200
	      	expect(flash[:success]).to be_present
			expect(User.find_by_email('test3@yero.co').password_reset_token).to eql ''
			
			post :login, :email => "test3@yero.co", :password => "11111111"
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['email']).to eql 'test3@yero.co'

	      	User.destroy_all
      
		end

	    it "Login" do
	    	birthday = (Time.now - 21.years)
			user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    post :login, :email => "test2@yero.co", :password => ""
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Login information missing."

	      	post :login, :email => "test2@yero.dco", :password => "sdf"
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Email address not found"

	      	post :login, :email => "test2@yero.co", :password => "wersfd"
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Your email or password is incorrect"

	      	post :login, :email => "test2@yero.co", :password => "123456"
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
		    post :login, {email: 'test2@yero.co', password: '123456'}
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql 2

	      	token = JSON.parse(response.body)['data']['token']
	      	request.env["X-API-TOKEN"] = token
	    	post :show
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

		    post :login, {email: 'test2@yero.co', password: '123456'}
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql 2

	      	token = JSON.parse(response.body)['data']['token']
	      	request.env["X-API-TOKEN"] = token
	    	post :index
	    	expect(response.status).to eql 200
	    	expect(JSON.parse(response.body)['message']).to eql nil
	    	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['percentage']).to eql 75

	      	gate = GlobalVariable.create!(name: "min_ppl_size", value: "2")
	      	post :index
	    	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['message']).to eql nil
	    	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 2

	      	post :index, :min_age => 25, :max_age => 27
	    	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['message']).to eql nil
	    	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 0

	      	post :index, :max_distance => 2
	    	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['message']).to eql nil
	    	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1

	      	post :index, :everyone => false
	    	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['message']).to eql nil
	    	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1
	      	expect(JSON.parse(response.body)['users'][0]['same_venue_badge']).to eql true
	      	expect(JSON.parse(response.body)['users'][0]['different_venue_badge']).to eql false

	      	active_in_venue_2.venue_id = 2
	      	active_in_venue_2.save!
	      	post :index, :everyone => false
	    	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['message']).to eql nil
	    	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1
	      	expect(JSON.parse(response.body)['users'][0]['same_venue_badge']).to eql false	      	
	      	expect(JSON.parse(response.body)['users'][0]['different_venue_badge']).to eql true

	      	post :block, :user_id => 3
	      	expect(response.status).to eql 200
	    	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']).to eql [3]

	      	post :block, :user_id => 30
	      	expect(response.status).to eql 200
	    	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Sorry, this user doesn't exist"

	      	post :block
	      	expect(response.status).to eql 200
	    	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql "Sorry, user_id required"

	      	post :index
	    	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['message']).to eql nil
	    	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['users'].count).to eql 1

	      	ua.is_active = false
	      	ua.save!
	      	post :index, :max_distance => 2
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

		    post :login, {email: 'test2@yero.co', password: '123456'}
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql 2

	      	token = JSON.parse(response.body)['data']['token']
	      	request.env["X-API-TOKEN"] = token

	      	friend = FriendByWhisper.create!(target_user_id: 3, origin_user_id: 2, friend_time: Time.now, viewed: false)
	      	post :requests_new
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 0
	      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 1
	      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 1

	      	post :requests_new
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 0
	      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 0
	      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

	      	friend.delete
	      	whisper = WhisperToday.create!(paper_owner_id: 2, target_user_id: 2, origin_user_id: 4, whisper_type: '2', viewed: false)
	      	post :requests_new
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 1
	      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 1
	      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

	      	post :requests_new
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 1
	      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 0
	      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

	      	whisper = WhisperToday.create!(paper_owner_id: 2, target_user_id: 2, origin_user_id: 3, whisper_type: '2', viewed: false)
	      	friend = FriendByWhisper.create!(target_user_id: 3, origin_user_id: 2, friend_time: Time.now, viewed: false)

	      	post :requests_new
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 2
	      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 2
	      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 1

	      	post :requests_new
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 2
	      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 0
	      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

	      	post :myfriends_new
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['friends'].count).to eql 1
	      	expect(JSON.parse(response.body)['data']['friends'][0]['actions']).to eql ['chat', 'delete']

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

		    post :login, {email: 'test2@yero.co', password: '123456'}
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql 2

	      	token = JSON.parse(response.body)['data']['token']
	      	request.env["X-API-TOKEN"] = token
	      	ReportType.create!(:id => 1, :report_type_name => "AAA")
	      	ReportType.create!(:id => 2, :report_type_name => "AwA")
	      	
	      	post :report, :user_id => 3, :type_id => 1
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(ReportUserHistory.count).to eql 1

	      	post :report, :user_id => 3, :type_id => 1
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(ReportUserHistory.count).to eql 2

	      	post :report, :user_id => 3, :type_id => 2
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(ReportUserHistory.count).to eql 3

	      	post :report, :user_id => 9, :type_id => 20
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

		    post :login, {email: 'test2@yero.co', password: '123456'}
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql 2

	      	token = JSON.parse(response.body)['data']['token']
	      	request.env["X-API-TOKEN"] = token

	      	post :update_chat_accounts, :instagram_id => '0 0', :snapchat_id => 'a a', :wechat_id => 'b b', :line_id => 'c c', :instagram_token => 'd d'
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['instagram_id']).to eql '00'
	      	expect(JSON.parse(response.body)['data']['snapchat_id']).to eql 'aa'
	      	expect(JSON.parse(response.body)['data']['wechat_id']).to eql 'bb'
	      	expect(JSON.parse(response.body)['data']['line_id']).to eql 'cc'
	      	expect(JSON.parse(response.body)['data']['instagram_token']).to eql 'dd'

	      	post :update_chat_accounts, :instagram_id => '10', :snapchat_id => '', :wechat_id => '', :line_id => '', :instagram_token => 'dd'
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql 'You must have at least one chatting account'
	      	expect(User.find(2).instagram_id).to eql '00'
	      	expect(User.find(2).snapchat_id).to eql 'aa'
	      	expect(User.find(2).wechat_id).to eql 'bb'
	      	expect(User.find(2).line_id).to eql 'cc'
	      	expect(User.find(2).instagram_token).to eql 'dd'


	      	post :update_profile, :avatars => [10, 11, 1], :introduction_1 => 'hello!saDFASFSADFWer!@#$%^&*#'
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['introduction_1']).to eql 'hello!saDFASFSADFWer!@#$%^&*#'
	      	expect(JSON.parse(response.body)['data']['avatars'][0]['avatar_id']).to eql 10
	      	expect(JSON.parse(response.body)['data']['avatars'][1]['avatar_id']).to eql 11
	      	expect(JSON.parse(response.body)['data']['avatars'][2]['avatar_id']).to eql 1
	      	
	      	post :update_profile, :avatars => [1, 11, 10], :introduction_1 => 'hello!saDFASFSADFWer!@#$%^&*#'
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['introduction_1']).to eql 'hello!saDFASFSADFWer!@#$%^&*#'
	      	expect(JSON.parse(response.body)['data']['avatars'][0]['avatar_id']).to eql 1
	      	expect(JSON.parse(response.body)['data']['avatars'][1]['avatar_id']).to eql 11
	      	expect(JSON.parse(response.body)['data']['avatars'][2]['avatar_id']).to eql 10
	      	
	      	post :update_settings, :exclusive => true
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['exclusive']).to eql true
	      	expect(User.find(2).exclusive).to eql true
	      	
	      	NotificationPreference.create!(name: "Network online")
			NotificationPreference.create!(name: "Enter venue network")
			NotificationPreference.create!(name: "Leave venue network")
	      	post :update_notification_preferences, :network_online => false, :enter_venue_network => false, :leave_venue_network => true
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']).to eql true
	      	expect(UserNotificationPreference.where(:user_id => 2).count).to eql 3

	      	post :update_notification_preferences, :network_online => true, :enter_venue_network => true, :leave_venue_network => false
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
			get :set_global_variable, :variable => '', :value => 'd'
			expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql 'Invalid params'
			get :set_global_variable, :variable => 'test', :value => '1'
			expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(GlobalVariable.find_by_name('test').value).to eql '1'

	      	get :set_global_variable, :variable => 'test', :value => '2'
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

		    post :login, {email: 'test2@yero.co', password: '123456'}
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql 2

	      	token = JSON.parse(response.body)['data']['token']
	      	request.env["X-API-TOKEN"] = token

	      	post :generate_reset_email_verify, :new_email => ""
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql 'New email cannot be blank'

	      	post :generate_reset_email_verify, :new_email => "test3@yero.co"
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql 'There is already an account with this email address.'

	      	post :generate_reset_email_verify, :new_email => "test30@yero.co"
	      	expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']).to eql true


	      	email_reset_token = User.find(2).email_reset_token

	      	post :email_reset, :email_reset_token => ''
		    expect(response.status).to eql 200
	      	expect(assigns(:message)).to eql 'Invalid email reset token'

			post :email_reset, :email_reset_token => email_reset_token+'sadf'
		    expect(response.status).to eql 200
	      	expect(assigns(:message)).to eql 'Invalid email reset token'

		    user_5 = User.create!(id:5, last_active: Time.now, first_name: "SF", email: "test30@yero.co", password: "123456", birthday: (birthday-20.years), gender: 'F', latitude: 49.3247234, longitude: -123.0706173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
		    post :email_reset, :email_reset_token => email_reset_token
		    expect(response.status).to eql 200
	      	expect(assigns(:message)).to eql 'There is already an account with this email address.'

	      	user_5.delete
	      	post :email_reset, :email_reset_token => email_reset_token
	      	expect(response.status).to eql 200
	      	expect(assigns(:message)).to eql 'Email verified successfully'
	      	expect(User.find(2).email).to eql "test30@yero.co"


	      	UserAvatar.delete_all
	      	User.delete_all
		end
	end


end

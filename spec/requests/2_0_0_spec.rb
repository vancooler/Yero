require 'spec_helper'

# Questions:
# 1. Still have "Join" button?
# 2. whispers last until 5AM or 12 hours?
# 3. Larger image -> size? 175*175
# 4. Sorting Algorithm -> time, venue badge, status
#*5. Real time?
# 6. Status, keep history?

describe 'V2.0.0' do
  	it "Auth" do
  		birthday = (Time.now - 21.years)
		user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
	    

      	get 'api/users', {}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['data']['code']).to eql 499

      	token = "user_2.generate_token"
      	get 'api/users?token=' + token, {}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['data']['code']).to eql 497

      	user = {:id => 200, :exp => (Time.now.to_i + 3600*24) } # expire in 24 hours
        secret = 'secret'
	    token = JWT.encode(user, secret)
	    get 'api/users?token=' + token, {}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['data']['code']).to eql 497

      	user = { } # expire in 24 hours
        secret = 'secret'
	    token = JWT.encode(user, secret)
	    get 'api/users?token=' + token, {}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['data']['code']).to eql 497

      	user = { :exp => (Time.now.to_i + 3600*24) } # expire in 24 hours
        secret = 'secret'
	    token = JWT.encode(user, secret)
	    get 'api/users?token=' + token, {}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['data']['code']).to eql 497

      	user = { :id => 2, :exp => (Time.now.to_i - 3600*24) } # expire in 24 hours
        secret = 'secret'
	    token = JWT.encode(user, secret)
	    get 'api/users?token=' + token, {}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['data']['code']).to eql 497


      	UserAvatar.delete_all
      	User.delete_all
  	end


  	it "Users" do
  		birthday = (Time.now - 21.years)
		user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    
	    user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "133456", birthday: birthday, gender: 'F', latitude: 49.3857334, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    ua = UserAvatar.create!(id: 3, user: user_3, is_active: true, order: 0)
	    
	    user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", email: "test4@yero.co", password: "143456", birthday: birthday, gender: 'F', latitude: 49.3857434, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    ua = UserAvatar.create!(id: 4, user: user_4, is_active: true, order: 0)
	    ga = GlobalVariable.create!(name: "min_ppl_size", value: "4")
	  	token = user_2.generate_token
      	get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['data']['code']).to eql 403
      	expect(JSON.parse(response.body)['data']['message']).to eql 'No photos'

	    ua = UserAvatar.create!(id: 2, user: user_2, is_active: true, order: 0)

	    get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['percentage']).to eql 75


      	token = user_2.generate_token
      	get 'api/users/433?token='+token, {}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['data']['code']).to eql 404

      	
      	get 'api/users/2?token='+token, {}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['id']).to eql 2


      	put 'api/current_user', {:token => token, :wechat_id => "we are ", :snapchat_id => "sa are", :line_id => "li are", :spotify_id => "sp are", :spotify_token => "AS DF", :instagram_id => "in are", :instagram_token => "SDd F", :timezone => "America/Vancouver", :latitude => 49.1, :longitude => -122.9, :introduction_1 => "He Has ...", :introduction_2 => "s?", :discovery => true, :exclusive => true}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['latitude']).to eql 49.1
      	expect(JSON.parse(response.body)['data']['wechat_id']).to eql "weare"
      	expect(JSON.parse(response.body)['data']['discovery']).to eql true
      	expect(JSON.parse(response.body)['data']['spotify_id']).to eql "spare"


      	put 'api/current_user', {:token => token, :wechat_id => "wedare", :snapchat_id => "saare", :line_id => "liare", :spotify_id => "spsdare", :spotify_token => "ASDF", :instagram_id => "inare", :instagram_token => "SDF", :timezone => "America/Vancouver", :latitude => 49.1, :longitude => -122.9, :introduction_1 => "He Has ...", :introduction_2 => "s?", :discovery => false, :exclusive => false}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['wechat_id']).to eql "wedare"
      	expect(JSON.parse(response.body)['data']['latitude']).to eql 49.1
      	expect(JSON.parse(response.body)['data']['discovery']).to eql false
      	expect(JSON.parse(response.body)['data']['spotify_id']).to eql "spsdare"

	    user_5 = User.create!(id:5, last_active: Time.now, first_name: "SF", email: "test5@yero.co", password: "153456", birthday: birthday, gender: 'F', latitude: 49.3857534, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    ua = UserAvatar.create!(id: 5, user: user_5, is_active: true, order: 0)
	    
	    user_6 = User.create!(id:6, last_active: Time.now, first_name: "SF", email: "test6@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    ua = UserAvatar.create!(id: 6, user: user_6, is_active: true, order: 0)
	    
	    user_7 = User.create!(id:7, last_active: Time.now, first_name: "SF", email: "test7@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    ua = UserAvatar.create!(id: 7, user: user_7, is_active: true, order: 0)
	    
	    user_8 = User.create!(id:8, last_active: Time.now, first_name: "SF", email: "test8@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    ua = UserAvatar.create!(id: 8, user: user_8, is_active: true, order: 0)
	    
	    user_9 = User.create!(id:9, last_active: Time.now, first_name: "SF", email: "test9@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3957234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    ua = UserAvatar.create!(id: 9, user: user_9, is_active: true, order: 0)
	    
	    get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['users'].count).to eql 7

      	get 'api/users?token='+token + '&page=0&per_page=4', {}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['users'].count).to eql 4

      	get 'api/current_user?token='+token, {}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['id']).to eql 2


      	get 'api/check-email', {}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['data']['code']).to eql 400

      	get 'api/check-email?email=test8@yero.co', {}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['data']['code']).to eql 403

      	get 'api/check-email?email=test81@yero.co', {}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true

		post 'api/signup', {:email=>'test8@yero.co', :first_name => "", :birthday => birthday, :gender => "M", :password => "123456"}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['data']['code']).to eql 400
      	expect(JSON.parse(response.body)['data']['message']).to eql 'Required fields cannot be blank'

      	post 'api/signup', {:email=>'test8@yero.co', :first_name => "AAA", :birthday => birthday, :gender => "M", :password => "123456"}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['data']['code']).to eql 400
      	expect(JSON.parse(response.body)['data']['message']).to eql 'This email has already been taken.'

      	post 'api/signup', {:email=>'test 85@yero.co', :first_name => "A AA", :birthday => birthday, :gender => " M ", :password => "123456", :wechat_id => "we sf", :instagram_id => "SFD d", :snapchat_id => "DSF SFD", :line_id => "SDF sDF"}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true

      	post 'api/signup', {:email=>'test8d5@yero.co', :first_name => "AAA", :birthday => birthday, :gender => "M", :password => "123456", :wechat_id => "wesf", :instagram_id => "SFDd", :snapchat_id => "DSSFD", :line_id => "SDsDF"}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true


		post 'api/login', {:email=>'test85@yero.co', :password => ""}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['data']['code']).to eql 400
      	expect(JSON.parse(response.body)['data']['message']).to eql 'Login information missing.'

      	post 'api/login', {:email=>'test85d@yero.co', :password => "123456"}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['data']['code']).to eql 403
      	expect(JSON.parse(response.body)['data']['message']).to eql 'Email address not found'

      	post 'api/login', {:email=>'test85@yero.co', :password => "12d3456"}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['data']['code']).to eql 403
      	expect(JSON.parse(response.body)['data']['message']).to eql 'Your email or password is incorrect'

      	post 'api/login', {:email=>'test85@yero.co', :password => "123456"}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['gender']).to eql "M"

      	post 'api/emails', {:new_email=>'', :token => token}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['data']['code']).to eql 400

      	post 'api/emails', {:new_email=>'test85@yero.co', :token => token}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['data']['code']).to eql 403

      	post 'api/emails', {:new_email=>'test85adf@yero.co', :token => token}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true

		post 'api/passwords', {:email=>'test8asfsf5@yero.co'}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['data']['code']).to eql 404

      	post 'api/passwords', {:email=>'test2@yero.co'}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true

		NotificationPreference.create!(name: "Network online")
		NotificationPreference.create!(name: "Enter venue network")
		NotificationPreference.create!(name: "Leave venue network")

		put 'api/user_notification_preferences', {:token => token, :network_online => false, :enter_venue_network => false, :leave_venue_network => true}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(UserNotificationPreference.where(:user_id => 2).count).to eql 3

		put 'api/user_notification_preferences', {:token => token, :network_online => true, :enter_venue_network => true, :leave_venue_network => false}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(UserNotificationPreference.where(:user_id => 2).count).to eql 0

		ReportType.create!(id: 1, report_type_name: "AAA")
		post 'api/report_user_histories', {:token => token, :user_id => 4, :type_id => 1, :reason => ''}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(ReportUserHistory.count).to eql 1

		token = user_3.generate_token
		post 'api/report_user_histories', {:token => token, :user_id => 4, :type_id => 1, :reason => ''}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(ReportUserHistory.count).to eql 2
		expect(ReportUserHistory.first.frequency).to eql 2

		post 'api/report_user_histories', {:token => token, :user_id => 43, :type_id => 5, :reason => ''}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
		expect(JSON.parse(response.body)['data']['code']).to eql 400

		post 'api/block_users', {:token => token}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
		expect(JSON.parse(response.body)['data']['code']).to eql 400

		post 'api/block_users', {:token => token, :user_id => 2345}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
		expect(JSON.parse(response.body)['data']['code']).to eql 404

		post 'api/block_users', {:token => token, :user_id => 4}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(JSON.parse(response.body)['data'].count).to eql 1
		expect(JSON.parse(response.body)['data'][0]['user']['id']).to eql 4

		post 'api/block_users', {:token => token, :user_id => 4}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(JSON.parse(response.body)['data'].count).to eql 1
		expect(JSON.parse(response.body)['data'][0]['user']['id']).to eql 4

		post 'api/block_users', {:token => token, :user_id => 2}, {'API-VERSION' => 'V2_0'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(JSON.parse(response.body)['data'].count).to eql 2
		expect(JSON.parse(response.body)['data'][0]['user']['id']).to eql 2

		BlockUser.delete_all
		ReportUserHistory.delete_all
		ReportType.delete_all
      	GlobalVariable.delete_all
      	NotificationPreference.delete_all
  		UserAvatar.delete_all
      	User.delete_all
  	end


  	it "User photos" do
  		birthday = (Time.now - 21.years)
		user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    ua = UserAvatar.create!(id: 2, user: user_2, is_active: true, order: 0)
	    
	    user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "133456", birthday: birthday, gender: 'F', latitude: 49.3857334, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    ua = UserAvatar.create!(id: 3, user: user_3, is_active: true, order: 0)
	    
	    user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", email: "test4@yero.co", password: "143456", birthday: birthday, gender: 'F', latitude: 49.3857434, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    ua = UserAvatar.create!(id: 4, user: user_4, is_active: true, order: 0)

	  	token = user_2.generate_token
      	

      	BlockUser.delete_all
		ReportUserHistory.delete_all
		ReportType.delete_all
      	GlobalVariable.delete_all
      	NotificationPreference.delete_all
  		UserAvatar.delete_all
      	User.delete_all
  	end


end
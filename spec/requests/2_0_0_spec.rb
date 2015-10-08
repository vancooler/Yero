require 'spec_helper'

describe 'V2.0.0' do
	before(:each) do
	  host! "api.yero.co"
	end
  	it "Auth" do
  		birthday = (Time.now - 21.years)
		user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
	    

      	get 'api/users', {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 499

      	token = "user_2.generate_token"
      	get 'api/users?token=' + token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 497

      	user = {:id => 200, :exp => (Time.now.to_i + 3600*24) } # expire in 24 hours
        secret = 'secret'
	    token = JWT.encode(user, secret)
	    get 'api/users?token=' + token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 497

      	user = { } # expire in 24 hours
        secret = 'secret'
	    token = JWT.encode(user, secret)
	    get 'api/users?token=' + token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 497

      	user = { :exp => (Time.now.to_i + 3600*24) } # expire in 24 hours
        secret = 'secret'
	    token = JWT.encode(user, secret)
	    get 'api/users?token=' + token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 497

      	user = { :id => 2, :exp => (Time.now.to_i - 3600*24) } # expire in 24 hours
        secret = 'secret'
	    token = JWT.encode(user, secret)
	    get 'api/users?token=' + token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 497


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
      	get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 403
      	expect(JSON.parse(response.body)['error']['message']).to eql 'No photos'

	    ua = UserAvatar.create!(id: 2, user: user_2, is_active: true, order: 0)

	    get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['percentage']).to eql 75


      	token = user_2.generate_token
      	get 'api/users/433?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 404

      	
      	get 'api/users/2?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['id']).to eql 2


      	put 'api/users', {:token => token, :wechat_id => "we are ", :snapchat_id => "sa are", :line_id => "li are", :spotify_id => "sp are", :spotify_token => "AS DF", :instagram_id => "in are", :instagram_token => "SDd F", :timezone => "America/Vancouver", :latitude => 49.1, :longitude => -122.9, :introduction_1 => "He Has ...", :introduction_2 => "s?", :discovery => true, :exclusive => true}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['latitude']).to eql 49.1
      	expect(JSON.parse(response.body)['data']['wechat_id']).to eql "weare"
      	expect(JSON.parse(response.body)['data']['discovery']).to eql true
      	expect(JSON.parse(response.body)['data']['spotify_id']).to eql "spare"


      	put 'api/users', {:token => token, :wechat_id => "wedare", :snapchat_id => "saare", :line_id => "liare", :spotify_id => "spsdare", :spotify_token => "ASDF", :instagram_id => "inare", :instagram_token => "SDF", :timezone => "America/Vancouver", :latitude => 49.1, :longitude => -122.9, :introduction_1 => "He Has ...", :introduction_2 => "s?", :discovery => false, :exclusive => false}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
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
	    
	    get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['users'].count).to eql 7

      	get 'api/users?token='+token + '&page=0&per_page=4', {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['users'].count).to eql 4
      	expect(JSON.parse(response.body)['pagination']['total_count']).to eql 7
      	expect(JSON.parse(response.body)['pagination']['page']).to eql 0
      	expect(JSON.parse(response.body)['pagination']['per_page']).to eql 4

      	
      	get 'api/verify', {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 400

      	get 'api/verify?email=test8@yero.co', {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 403

      	get 'api/verify?email=test81@yero.co', {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true

		post 'api/signup', {:email=>'test8@yero.co', :first_name => "", :birthday => birthday, :gender => "M", :password => "123456"}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 400
      	expect(JSON.parse(response.body)['error']['message']).to eql 'Required fields cannot be blank'

      	post 'api/signup', {:email=>'test8@yero.co', :first_name => "AAA", :birthday => birthday, :gender => "M", :password => "123456"}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 400
      	expect(JSON.parse(response.body)['error']['message']).to eql 'This email has already been taken.'

      	post 'api/signup', {:email=>'test 85@yero.co', :first_name => "A AA", :birthday => birthday, :gender => " M ", :password => "123456", :wechat_id => "we sf", :instagram_id => "SFD d", :snapchat_id => "DSF SFD", :line_id => "SDF sDF"}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true

      	post 'api/signup', {:email=>'test8d5@yero.co', :first_name => "AAA", :birthday => birthday, :gender => "M", :password => "123456", :wechat_id => "wesf", :instagram_id => "SFDd", :snapchat_id => "DSSFD", :line_id => "SDsDF"}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true


		post 'api/login', {:email=>'test85@yero.co', :password => ""}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 400
      	expect(JSON.parse(response.body)['error']['message']).to eql 'Login information missing.'

      	post 'api/login', {:email=>'test85d@yero.co', :password => "123456"}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 403
      	expect(JSON.parse(response.body)['error']['message']).to eql 'Email address not found'

      	post 'api/login', {:email=>'test85@yero.co', :password => "12d3456"}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 403
      	expect(JSON.parse(response.body)['error']['message']).to eql 'Your email or password is incorrect'

      	post 'api/login', {:email=>'test85@yero.co', :password => "123456"}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['gender']).to eql "M"

      	post 'api/emails', {:new_email=>'', :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 400

      	post 'api/emails', {:new_email=>'test85@yero.co', :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 403

      	post 'api/emails', {:new_email=>'test85adf@yero.co', :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true

		post 'api/passwords', {:email=>'test8asfsf5@yero.co'}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 404

      	post 'api/passwords', {:email=>'test2@yero.co'}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true

		NotificationPreference.create!(name: "Network online", default_value: true)
		NotificationPreference.create!(name: "Enter venue network", default_value: true)
		NotificationPreference.create!(name: "Leave venue network", default_value: false)

		put 'api/user_notification_preferences', {:token => token, :notification_settings => {:name => "Network online", :value => 0 }}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(UserNotificationPreference.where(:user_id => 2).count).to eql 1

		put 'api/user_notification_preferences', {:token => token, :notification_settings => {:name => "Leave venue network", :value => 1} }, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(UserNotificationPreference.where(:user_id => 2).count).to eql 2

		put 'api/user_notification_preferences', {:token => token, :notification_settings => {:name => "Network online", :value => 1} }, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(UserNotificationPreference.where(:user_id => 2).count).to eql 1


		put 'api/user_notification_preferences', {:token => token, :notification_settings => {:name => "Leave venue network", :value => 0} }, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(UserNotificationPreference.where(:user_id => 2).count).to eql 0

		ReportType.create!(id: 1, report_type_name: "AAA")
		post 'api/report_user_histories', {:token => token, :user_id => 4, :type_id => 1, :reason => ''}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(ReportUserHistory.count).to eql 1

		token = user_3.generate_token
		post 'api/report_user_histories', {:token => token, :user_id => 4, :type_id => 1, :reason => ''}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(ReportUserHistory.count).to eql 2
		expect(ReportUserHistory.first.frequency).to eql 2

		post 'api/report_user_histories', {:token => token, :user_id => 43, :type_id => 5, :reason => ''}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
		expect(JSON.parse(response.body)['error']['code']).to eql 400

		post 'api/block_users', {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
		expect(JSON.parse(response.body)['error']['code']).to eql 400

		post 'api/block_users', {:token => token, :user_id => 2345}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
		expect(JSON.parse(response.body)['error']['code']).to eql 404

		post 'api/block_users', {:token => token, :user_id => 4}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(JSON.parse(response.body)['data'].count).to eql 1
		expect(JSON.parse(response.body)['data'][0]['user']['id']).to eql 4

		post 'api/block_users', {:token => token, :user_id => 4}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(JSON.parse(response.body)['data'].count).to eql 1
		expect(JSON.parse(response.body)['data'][0]['user']['id']).to eql 4

		post 'api/block_users', {:token => token, :user_id => 2}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(JSON.parse(response.body)['data'].count).to eql 2
		expect(JSON.parse(response.body)['data'][0]['user']['id']).to eql 2

		get 'api/block_users?page=0&per_page=1', {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(JSON.parse(response.body)['data'].count).to eql 1
		expect(JSON.parse(response.body)['data'][0]['user']['id']).to eql 2

		delete 'api/block_users/29', {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false

		delete 'api/block_users/2', {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(BlockUser.count).to eql 1

		BlockUser.create!(origin_user_id: 3, target_user_id: 2)

		expect(BlockUser.count).to eql 2

		delete 'api/collection', {:token => token, :object_type => "block_users", :ids => [2, 4]}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(BlockUser.count).to eql 0


		BlockUser.delete_all
		TimeZonePlace.delete_all
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
	    # ua = UserAvatar.create!(id: 3, user: user_3, is_active: true, order: 0)
	    
	    # user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", email: "test4@yero.co", password: "143456", birthday: birthday, gender: 'F', latitude: 49.3857434, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    # ua = UserAvatar.create!(id: 4, user: user_4, is_active: true, order: 0)

	  	token = user_3.generate_token
      	
      	post 'api/avatars', {:token => token, :avatar_url => '', :thumb_url => 'https://s3-us-west-2.amazonaws.com/yero-development/uploads/user_avatar/avatar/v2_1/thumb.jpg'}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false

	  	post 'api/avatars', {:token => token, :avatar_url => 'https://s3-us-west-2.amazonaws.com/yero-development/uploads/user_avatar/avatar/v2_1/avatar.jpg', :thumb_url => 'https://s3-us-west-2.amazonaws.com/yero-development/uploads/user_avatar/avatar/v2_1/thumb.jpg'}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(JSON.parse(response.body)['data']['avatars'].count).to eql 1
		expect(JSON.parse(response.body)['data']['avatars'][0]['thumbnail']).to eql 'https://s3-us-west-2.amazonaws.com/yero-development/uploads/user_avatar/avatar/v2_1/thumb.jpg'
		expect(JSON.parse(response.body)['data']['avatars'][0]['avatar']).to eql 'https://s3-us-west-2.amazonaws.com/yero-development/uploads/user_avatar/avatar/v2_1/avatar.jpg'
		expect(JSON.parse(response.body)['data']['avatars'][0]['order']).to eql 0
		avatar_id = JSON.parse(response.body)['data']['avatars'][0]['avatar_id']

		post 'api/avatars', {:token => token, :avatar_url => 'https://s3-us-west-2.amazonaws.com/yero-development/uploads/user_avatar/avatar/v2_1/avatar_2.jpg', :thumb_url => 'https://s3-us-west-2.amazonaws.com/yero-development/uploads/user_avatar/avatar/v2_1/thumb_2.jpg'}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(JSON.parse(response.body)['data']['avatars'].count).to eql 2
		expect(JSON.parse(response.body)['data']['avatars'][1]['thumbnail']).to eql 'https://s3-us-west-2.amazonaws.com/yero-development/uploads/user_avatar/avatar/v2_1/thumb_2.jpg'
		expect(JSON.parse(response.body)['data']['avatars'][1]['avatar']).to eql 'https://s3-us-west-2.amazonaws.com/yero-development/uploads/user_avatar/avatar/v2_1/avatar_2.jpg'
		expect(JSON.parse(response.body)['data']['avatars'][1]['order']).to eql 1
		avatar_1_id = JSON.parse(response.body)['data']['avatars'][1]['avatar_id']

		put 'api/avatars/'+avatar_id.to_s, {:token => token, :avatar_url => '', :thumb_url => 'https://s3-us-west-2.amazonaws.com/yero-development/uploads/user_avatar/avatar/v2_1/thumb.jpg'}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false

		put 'api/avatars/'+avatar_id.to_s, {:token => token, :avatar_url => 'https://s3-us-west-2.amazonaws.com/yero-development/uploads/user_avatar/avatar/v2_1/avatar_3.jpg', :thumb_url => 'https://s3-us-west-2.amazonaws.com/yero-development/uploads/user_avatar/avatar/v2_1/thumb_3.jpg'}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(JSON.parse(response.body)['data']['avatars'].count).to eql 2
		expect(JSON.parse(response.body)['data']['avatars'][0]['thumbnail']).to eql 'https://s3-us-west-2.amazonaws.com/yero-development/uploads/user_avatar/avatar/v2_1/thumb_3.jpg'
		expect(JSON.parse(response.body)['data']['avatars'][0]['avatar']).to eql 'https://s3-us-west-2.amazonaws.com/yero-development/uploads/user_avatar/avatar/v2_1/avatar_3.jpg'
		expect(JSON.parse(response.body)['data']['avatars'][0]['order']).to eql 0


		delete 'api/avatars/3300', {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false

		delete 'api/avatars/'+avatar_id.to_s, {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql true
		expect(JSON.parse(response.body)['data']['avatars'].count).to eql 1
		expect(JSON.parse(response.body)['data']['avatars'][0]['thumbnail']).to eql 'https://s3-us-west-2.amazonaws.com/yero-development/uploads/user_avatar/avatar/v2_1/thumb_2.jpg'
		expect(JSON.parse(response.body)['data']['avatars'][0]['avatar']).to eql 'https://s3-us-west-2.amazonaws.com/yero-development/uploads/user_avatar/avatar/v2_1/avatar_2.jpg'
		expect(JSON.parse(response.body)['data']['avatars'][0]['order']).to eql 0

		
		token = user_2.generate_token
      	delete 'api/avatars/'+avatar_1_id.to_s, {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false
		put 'api/avatars/'+avatar_1_id.to_s, {:token => token, :avatar_url => 'haha', :thumb_url => 'https://s3-us-west-2.amazonaws.com/yero-development/uploads/user_avatar/avatar/v2_1/thumb.jpg'}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
		expect(response.status).to eql 200
		expect(JSON.parse(response.body)['success']).to eql false



      	BlockUser.delete_all
		ReportUserHistory.delete_all
		ReportType.delete_all
      	GlobalVariable.delete_all
      	NotificationPreference.delete_all
  		UserAvatar.delete_all
      	User.delete_all
  	end

  	it "Venues" do
  		birthday = (Time.now - 21.years)
		user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    ua = UserAvatar.create!(id: 2, user: user_2, is_active: true, order: 0)


	    venue_network = VenueNetwork.create!(id:1, name: "V")
        venue_type = VenueType.create!(id:1, name:"Festivals")
        venue_type_2 = VenueType.create!(id:2, name:"Club")
        TimeZonePlace.create(timezone: "America/Vancouver")
        venue_1 = Venue.create!(id:1, venue_network: venue_network, name: "AAA", venue_type:venue_type, latitude: 49.153, longitude: -123.436, featured: false, timezone: "America/Vancouver", start_time: Time.now-13.hours, end_time: Time.now+13.hours)
        venue_2 = Venue.create!(id:2, venue_network: venue_network, name: "BBB", venue_type:venue_type, latitude: 49.423, longitude: -123.532, featured: false)
        venue_3 = Venue.create!(id:3, venue_network: venue_network, name: "CCC", venue_type:venue_type, latitude: 49.463, longitude: -123.312, featured: false, timezone: "America/Vancouver", start_time: Time.now-13.hours, end_time: Time.now+3.hours)
        venue_4 = Venue.create!(id:4, venue_network: venue_network, name: "DDD", venue_type:venue_type_2, latitude: 49.353, longitude: -123.424, featured: true)
        venue_5 = Venue.create!(id:5, venue_network: venue_network, name: "CCC", venue_type:venue_type, latitude: 49.423, longitude: -123.532, featured: false, timezone: "America/Vancouver", start_time: Time.now-13.hours, end_time: Time.now+13.hours)
        VenueAvatar.create!(id: 2, venue_id: 1, default: true)
        VenueAvatar.create!(id: 3, venue_id: 2, default: true)
        VenueAvatar.create!(id: 4, venue_id: 3, default: true)
        VenueAvatar.create!(id: 5, venue_id: 4, default: true)
        VenueAvatar.create!(id: 6, venue_id: 5, default: true)



	   	token = user_2.generate_token

	   	get 'api/venues?page=1&per_page=2&latitude=49.4563&longitude=-122.8787&distance=1000&without_featured_venues=1&token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
	   	expect(response.status).to eql 200
		expect(JSON.parse(response.body)['data'].count).to eql 2
		expect(JSON.parse(response.body)['pagination']['page']).to eql 1
		expect(JSON.parse(response.body)['pagination']['per_page']).to eql 2
		expect(JSON.parse(response.body)['pagination']['total_count']).to eql 4

		get 'api/venues?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
	   	expect(response.status).to eql 200
		expect(JSON.parse(response.body)['data'].count).to eql 5
		expect(JSON.parse(response.body)['data'][0]['id']).to eql 3

		# expect(Venue.nearby_networks(49, -123, 100).length).to eql 5
		# expect(Venue.festivals(-49, 120).length).to eql 4
		# expect(Venue.colleges(49, -10).length).to eql 0
		# expect(Venue.nightlifes(49, -10).length).to eql 1
		# expect(Venue.stadiums(49, -10).length).to eql 0
		get 'api/venue_types?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
	   	expect(response.status).to eql 200
		expect(JSON.parse(response.body)['data'].count).to eql 3
		expect(JSON.parse(response.body)['data'][0]['title']).to eql "NEARBY"
		expect(JSON.parse(response.body)['data'][1]['title']).to eql "FESTIVALS"
		expect(JSON.parse(response.body)['data'][2]['title']).to eql "NIGHTLIFE"
		expect(JSON.parse(response.body)['data'][0]['total']).to eql 5
		expect(JSON.parse(response.body)['data'][1]['total']).to eql 4
		expect(JSON.parse(response.body)['data'][2]['total']).to eql 1


		TimeZonePlace.delete_all
		VenueAvatar.delete_all
		Venue.delete_all
		VenueType.delete_all
		UserAvatar.delete_all
		User.delete_all
		VenueNetwork.delete_all
	end


  	it "Enter/leave venue" do
  		birthday = (Time.now - 21.years)
		user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)

	    venue_network = VenueNetwork.create!(id:1, name: "V", timezone: "America/Vancouver")
      	venue = Venue.create!(id:1, venue_network: venue_network, name: "AAA")
      	beacon = Beacon.create!(key: "Vancouver_TestVenue_test", venue_id: 1)
	    venue_2 = Venue.create!(id:2, venue_network: venue_network, name: "BBB")
      	beacon_2 = Beacon.create!(key: "Vancouver_TestVenue2_test", venue_id: 2)
	    
      	token = user_2.generate_token


      	post 'api/venues/sfsdf', {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 404

      	post 'api/venues/Vancouver_TestVenue_test', {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ActiveInVenue.first.beacon.key).to eql "Vancouver_TestVenue_test"
      	expect(ActiveInVenue.count).to eql 1
      	expect(ActiveInVenueNetwork.count).to eql 1

      	post 'api/venues/Vancouver_TestVenue2_test', {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ActiveInVenue.count).to eql 1
      	expect(ActiveInVenue.first.beacon.key).to eql "Vancouver_TestVenue2_test"
      	expect(ActiveInVenueNetwork.count).to eql 1


      	delete 'api/venues', {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ActiveInVenue.count).to eql 0
      	expect(ActiveInVenueNetwork.count).to eql 1

      	delete 'api/venues', {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ActiveInVenue.count).to eql 0
      	expect(ActiveInVenueNetwork.count).to eql 1

      	post 'api/venues/Vancouver_TestVenue_test', {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ActiveInVenue.count).to eql 1
      	expect(ActiveInVenue.first.beacon.key).to eql "Vancouver_TestVenue_test"
      	expect(ActiveInVenueNetwork.count).to eql 1


      	ActiveInVenueNetwork.five_am_cleanup(venue_network, [2])
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
      	get 'api/friends/3?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 403
      	expect(JSON.parse(response.body)['error']['message']).to eql "Sorry, you don't have access to it"

      	get 'api/friends?page=0&per_page=3&token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['friends'].count).to eql 0

      	token = user_2.generate_token
      	get 'api/friends/3?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['id']).to eql 3
      	expect(JSON.parse(response.body)['data']['object']['id']).to eql 3

      	get 'api/friends/8?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 404
      	expect(JSON.parse(response.body)['error']['message']).to eql 'Sorry, cannot find the friend'

      	get 'api/friends/4?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 403
      	expect(JSON.parse(response.body)['error']['message']).to eql "Sorry, you don't have access to it"

      	get 'api/friends?page=0&per_page=3&token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['friends'].count).to eql 1
      	expect(JSON.parse(response.body)['data']['friends'][0]['id']).to eql 3
      	expect(JSON.parse(response.body)['data']['friends'][0]['object']['id']).to eql 3
      	expect(JSON.parse(response.body)['pagination']['page']).to eql 0
      	expect(JSON.parse(response.body)['pagination']['total_count']).to eql 1

      	# Block
      	BlockUser.create!(origin_user_id: 2, target_user_id: 3)
      	token = user_3.generate_token
      	get 'api/friends/2?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 403
      	expect(JSON.parse(response.body)['error']['message']).to eql "Sorry, you don't have access to it"

      	delete 'api/collection', {:token => token, :object_type => "friends", :ids => [2, 4]}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(FriendByWhisper.count).to eql 0


      	BlockUser.delete_all
      	# No photo
      	UserAvatar.delete_all
      	token = user_3.generate_token
      	get 'api/friends/2?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 403
      	expect(JSON.parse(response.body)['error']['message']).to eql "Sorry, you don't have access to it"


      	FriendByWhisper.delete_all
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

      	get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['users'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['users'][0]['id']).to eql 4
      	expect(JSON.parse(response.body)['data']['users'][0]['whisper_sent']).to eql false
      	expect(JSON.parse(response.body)['data']['users'][0]['actions'].count).to eql 1

      	post "api/whispers", {:notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
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

      	post "api/whispers", {:notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['message']).to eql "Cannot send more whispers"

      	get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['users'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['users'][1]['actions'].count).to eql 0


      	whisper_time = WhisperSent.first.whisper_time

      	# user_3 -> user_2 reply
      	token = user_3.generate_token

      	puts "LAST ACTIVE TIME:"
      	puts User.find(2).last_active
      	puts User.find(4).last_active
      	get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['users'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['users'][0]['id']).to eql 2
      	expect(JSON.parse(response.body)['data']['users'][0]['actions'].count).to eql 3

      	get 'api/whispers/aaa2?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['whisper_id']).to eql 'aaa2'
      	expect(JSON.parse(response.body)['data']['intro_message']).to eql "Hi!"
      	expect(JSON.parse(response.body)['data']['messages_array'].count).to eql 1
      	expect(JSON.parse(response.body)['data']['messages_array'][0]['speaker_id']).to eql 2
      	expect(JSON.parse(response.body)['data']['messages_array'][0]['message']).to eql 'Hi!'

      	get 'api/whispers?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 1
      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'].count).to eql 1
      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'][0]['message']).to eql 'Hi!'
      	expect(JSON.parse(response.body)['data']['whispers'][0]['actions'].count).to eql 3
      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 1
      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0


      	post "api/whispers", {:notification_type => '2', :target_id => '2', :intro => "Hello!", :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
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

      	post "api/whispers", {:notification_type => '2', :target_id => '2', :intro => "Hi!", :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['message']).to eql "Cannot send more whispers"

      	get 'api/whispers?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 1
      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'][0]['message']).to eql 'Hello!'
      	expect(JSON.parse(response.body)['data']['whispers'][0]['actions'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 0
      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

      	get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['users'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['users'][0]['actions'].count).to eql 2


      	# user_2 -> user_3 reply again
      	token = user_2.generate_token

      	get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['users'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['users'][0]['actions'].count).to eql 2


      	get 'api/whispers/aaa2?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['whisper_id']).to eql 'aaa2'
      	expect(JSON.parse(response.body)['data']['intro_message']).to eql "Hello!"
      	expect(JSON.parse(response.body)['data']['messages_array'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['messages_array'][0]['speaker_id']).to eql 3
      	expect(JSON.parse(response.body)['data']['messages_array'][0]['message']).to eql 'Hello!'

		get 'api/whispers?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 1
      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'][0]['message']).to eql 'Hello!'
      	expect(JSON.parse(response.body)['data']['whispers'][0]['actions'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 1
      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

      	post "api/whispers", {:notification_type => '2', :target_id => '3', :intro => "Hello Again!", :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
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

      	post "api/whispers", {:notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['message']).to eql "Cannot send more whispers"

      	get 'api/whispers?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 0
      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 0
      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

      	get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['users'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['users'][0]['actions'].count).to eql 0

      	get 'api/whispers/aaa2asdf?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 404
      	expect(JSON.parse(response.body)['error']['message']).to eql "Sorry, cannot find the whisper"


      	user_5 = User.create!(id:5, last_active: Time.now, first_name: "SF", email: "test5@yero.co", password: "123556", birthday: (birthday-20.years), gender: 'F', latitude: 59.3257235, longitude: -123.0706173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: false, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    ua_5 = UserAvatar.create!(id: 4, user: user_5, is_active: true, order: 0)
		
      	token = user_5.generate_token
      	get 'api/whispers/aaa2?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 403
      	expect(JSON.parse(response.body)['error']['message']).to eql "Sorry, you don't have access to it"
      	user_5.delete

      	# Block
      	BlockUser.create!(origin_user_id: 2, target_user_id: 3)
      	token = user_3.generate_token
      	get 'api/whispers/aaa2?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 403
      	expect(JSON.parse(response.body)['error']['message']).to eql "Sorry, you don't have access to it"

      	BlockUser.delete_all
      	# No photo
      	ua.delete
	    
      	token = user_3.generate_token

      	get 'api/whispers/aaa2?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 403
      	expect(JSON.parse(response.body)['error']['message']).to eql "Sorry, you don't have access to it"


      	ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)

      	# accept it
      	token = user_3.generate_token

      	get 'api/whispers/2?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['whisper_id']).to eql 'aaa2'
      	expect(JSON.parse(response.body)['data']['intro_message']).to eql "Hello Again!"
      	expect(JSON.parse(response.body)['data']['messages_array'].count).to eql 3
      	expect(JSON.parse(response.body)['data']['messages_array'][0]['speaker_id']).to eql 2
      	expect(JSON.parse(response.body)['data']['messages_array'][0]['message']).to eql 'Hello Again!'

      	get 'api/whispers?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 1
      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'].count).to eql 3
      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'][0]['message']).to eql 'Hello Again!'
      	expect(JSON.parse(response.body)['data']['whispers'][0]['actions'].count).to eql 3
      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 1
      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

      	get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['users'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['users'][0]['actions'].count).to eql 3
      	expect(JSON.parse(response.body)['data']['users'][0]['messages_array'].count).to eql 3
      	expect(JSON.parse(response.body)['data']['users'][0]['whisper_id']).to eql 'aaa2'



      	put 'api/whispers/aaa2', {:accepted => false, :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['message']).to eql 'Sorry cannot execute the action'

      	put 'api/whispers/aaa', {:accepted => true, :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['message']).to eql 'Sorry, cannot find the whisper'

      	BlockUser.create!(origin_user_id: 2, target_user_id: 3)
      	put 'api/whispers/aaa2', {:accepted => true, :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['message']).to eql "User blocked"
      	BlockUser.delete_all
      	put 'api/whispers/aaa2', {:accepted => true, :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(WhisperToday.count).to eql 0
      	expect(WhisperSent.count).to eql 1
      	expect(WhisperSent.first.whisper_time).to eql whisper_time
      	expect(WhisperReply.count).to eql 0	      	
      	expect(RecentActivity.count).to eql 8
      	expect(FriendByWhisper.count).to eql 1

      	get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['users'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['users'][0]['actions'].count).to eql 1



      	token = user_2.generate_token

      	get 'api/whispers?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 0
      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 1
      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 1

      	get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['users'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['users'][0]['actions'].count).to eql 0

      	puts "TEEEEEE"
      	puts user_2.people_list_2_0(-1, "A", 0, 54, nil, 0, 65, true, 0, 7).inspect

      	# expect(JSON.parse(response.body)['data']['users'][0]['friend']).to eql true

      	get 'api/whispers/3?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 404
      	expect(JSON.parse(response.body)['error']['message']).to eql 'Sorry, cannot find the whisper'

      	delete 'api/friends/33', {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false

      	delete 'api/friends/3', {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(FriendByWhisper.count).to eql 0


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

      	get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['users'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['users'][0]['id']).to eql 4
      	expect(JSON.parse(response.body)['data']['users'][0]['whisper_sent']).to eql false
      	expect(JSON.parse(response.body)['data']['users'][0]['actions'].count).to eql 1

      	post "api/whispers", {:notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
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

      	post "api/whispers", {:notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['message']).to eql "Cannot send more whispers"

      	get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['users'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['users'][1]['actions'].count).to eql 0


      	whisper_time = WhisperSent.first.whisper_time

      	# user_3 -> user_2 reply
      	token = user_3.generate_token

      	get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['users'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['users'][0]['actions'].count).to eql 3

      	get 'api/whispers/aaa2?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['whisper_id']).to eql 'aaa2'
      	expect(JSON.parse(response.body)['data']['intro_message']).to eql "Hi!"
      	expect(JSON.parse(response.body)['data']['actions'].count).to eql 3
      	expect(JSON.parse(response.body)['data']['messages_array'].count).to eql 1
      	expect(JSON.parse(response.body)['data']['messages_array'][0]['speaker_id']).to eql 2
      	expect(JSON.parse(response.body)['data']['messages_array'][0]['message']).to eql 'Hi!'

      	get 'api/whispers?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 1
      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'].count).to eql 1
      	expect(JSON.parse(response.body)['data']['whispers'][0]['messages_array'][0]['message']).to eql 'Hi!'
      	expect(JSON.parse(response.body)['data']['whispers'][0]['actions'].count).to eql 3
      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 1
      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

      	put 'api/whispers/aaa2', {:declined => true, :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true


      	expect(WhisperToday.count).to eql 0
      	expect(WhisperReply.count).to eql 0

		ws = WhisperSent.last
		ws.whisper_time = Time.now - 53.hours
		ws.save!

      	get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['users'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['users'][0]['actions'].count).to eql 1

      	get 'api/whispers?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['whispers'].count).to eql 0
      	expect(JSON.parse(response.body)['data']['badge_number']['whisper_number']).to eql 0
      	expect(JSON.parse(response.body)['data']['badge_number']['friend_number']).to eql 0

      	token = user_2.generate_token
      	post "api/whispers", {:notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
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

      	get 'api/activities?per_page=48&page=0&token='+ token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data'].count).to eql 2
      	expect(JSON.parse(response.body)['pagination']['total_count']).to eql 2


      	token = user_3.generate_token
      	delete 'api/collection', {:token => token, :object_type => "whispers", :ids => []}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['message']).to eql 'Invalid parameters'


      	delete 'api/collection', {:token => token, :object_type => "whispers", :ids => ['aaa2']}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true

      	get 'api/users?token='+token, {}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['users'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['users'][0]['actions'].count).to eql 1
      	expect(WhisperToday.count).to eql 0
      	expect(WhisperReply.count).to eql 0


      	ws = WhisperSent.last
		ws.whisper_time = Time.now - 53.hours
		ws.save!

		token = user_2.generate_token
      	
      	token = user_2.generate_token
      	post "api/whispers", {:notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
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
      	expect(RecentActivity.count).to eql 6


      	token = user_3.generate_token
      	delete 'api/whispers/2', {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(WhisperToday.count).to eql 0

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

      	post "api/whispers", {:notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
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

      	post "api/whispers", {:notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['message']).to eql "Cannot send more whispers"

      	WhisperSent.delete_all

      	post "api/whispers", {:notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true

      	# user_3 -> user_2 reply
      	token = user_3.generate_token
      	post "api/whispers", {:notification_type => '2', :target_id => '2', :intro => "Hello!", :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
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
      	post "api/whispers", {:notification_type => '2', :target_id => '3', :intro => "Hello Again!", :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true

      	whisper = WhisperToday.first
      	whisper.created_at = Time.now - 48.hours - 1.second
      	whisper.updated_at = Time.now - 48.hours - 1.second
      	whisper.save!

      	WhisperToday.expire
      	expect(WhisperToday.count).to eql 0
      	expect(WhisperReply.count).to eql 0

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

      	post "api/whispers", {:notification_type => '2', :target_id => '3', :intro => "Hi!", :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
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

      	post "api/whispers", {:notification_type => '2', :target_id => '2', :intro => "Hi!", :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
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
      	put 'api/whispers/aaa2', {:declined => true, :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true


      	expect(WhisperToday.count).to eql 0
      	expect(WhisperReply.count).to eql 0

      	delete 'api/activities/9347876', {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false

      	activity = RecentActivity.last
      	delete 'api/activities/'+activity.id.to_s, {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(RecentActivity.count).to eql 3



      	token = user_3.generate_token
      	put 'api/whispers/aaa2', {:declined => true, :token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['message']).to eql "Sorry, cannot find the whisper"



	    WhisperToday.delete_all
	    WhisperSent.delete_all
	    WhisperReply.delete_all
	    RecentActivity.delete_all
	    UserAvatar.delete_all
	    User.delete_all
	end



	it "Shouts" do
    	birthday = (Time.now - 21.years)
		user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", username: "user_2", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
	    
	    user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", username: "user_3", email: "test3@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746133, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    ua_2 = UserAvatar.create!(id: 2, user: user_3, is_active: true, order: 0)
	    
	    user_4 = User.create!(id:4, last_active: Time.now, first_name: "SF", username: "user_4", email: "test4@yero.co", password: "123456", birthday: (birthday-20.years), gender: 'F', latitude: 49.3247234, longitude: -123.0706173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: false, current_city: "Vancouver", timezone_name: "America/Vancouver")
	    ua_4 = UserAvatar.create!(id: 3, user: user_4, is_active: true, order: 0)

	    venue_network = VenueNetwork.create!(id:1, name: "V", timezone: "America/Vancouver")
      	venue = Venue.create!(id:1, venue_network: venue_network, name: "AAA", latitude: 49.534235, longitude: -123.063472)
      	beacon = Beacon.create!(key: "Vancouver_TestVenue_test", venue_id: 1)
	    venue_2 = Venue.create!(id:2, venue_network: venue_network, name: "BBB")
      	beacon_2 = Beacon.create!(key: "Vancouver_TestVenue2_test", venue_id: 2)
	    
      	token = user_2.generate_token
      	# user_2 enter venue 
      	post 'api/venues/Vancouver_TestVenue_test', {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ActiveInVenue.first.beacon.key).to eql "Vancouver_TestVenue_test"
      	expect(ActiveInVenue.count).to eql 1
      	expect(ActiveInVenueNetwork.count).to eql 1

      	# user_2 post shout
      	post 'api/shouts', {:token => token, :body => "AAA", :allow_nearby => false}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(Shout.count).to eql 1
      	shout_1 = Shout.last

      	post 'api/shouts', {:token => token, :body => "BBB", :allow_nearby => true}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(Shout.count).to eql 2
      	shout_2 = Shout.last

      	# expect(Shout.list(user_2, 'hot', 1).count).to eql 2
      	get 'api/shouts', {:token => token, :order_by => "hot", :venue => 1}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['shouts'].count).to eql 2

      	get 'api/shouts', {:token => token, :order_by => "new"}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['shouts'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['shouts'][0]['id']).to eql shout_2.id

      	# user_3
      	token = user_3.generate_token
      	get 'api/shouts', {:token => token, :order_by => "hot", :venue => 1}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['shouts'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['shouts'][0]['id']).to eql shout_2.id

      	get 'api/shouts', {:token => token, :order_by => "new"}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['shouts'].count).to eql 1

      	post 'api/shouts', {:token => token, :body => "CCC", :allow_nearby => true}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(Shout.count).to eql 3
      	shout_3 = Shout.last

      	get 'api/shouts', {:token => token, :order_by => "new", :venue => 1}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['shouts'].count).to eql 2

      	get 'api/shouts', {:token => token, :order_by => "new"}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['shouts'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['shouts'][0]['id']).to eql shout_3.id

      	expect(User.find(2).point).to eql 4
      	expect(User.find(3).point).to eql 2
      	expect(User.find(4).point).to eql 0

      	put 'api/shouts/'+shout_2.id.to_s, {:token => token, :upvote => false}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ShoutVote.count).to eql 1
      	expect(shout_2.total_upvotes).to eql -1

      	expect(User.find(2).point).to eql 4
      	expect(User.find(3).point).to eql 3
      	expect(User.find(4).point).to eql 0

      	put 'api/shouts/'+shout_2.id.to_s, {:token => token, :upvote => true}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ShoutVote.count).to eql 1
      	expect(shout_2.total_upvotes).to eql 1

      	expect(User.find(2).point).to eql 6
      	expect(User.find(3).point).to eql 3
      	expect(User.find(4).point).to eql 0


      	post 'api/shout_comments', {:token => token, :body => "DDD", :shout_id => shout_2.id}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ShoutComment.count).to eql 1
      	shout_comment_1 = ShoutComment.last



      	get 'api/shouts', {:token => token, :order_by => "hot", :my_comments => true}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['shouts'].count).to eql 1


      	expect(User.find(2).point).to eql 6
      	expect(User.find(3).point).to eql 5
      	expect(User.find(4).point).to eql 0



      	# user_4
      	token = user_4.generate_token
      	put 'api/shouts/'+shout_2.id.to_s, {:token => token, :upvote => true}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ShoutVote.count).to eql 2
      	expect(shout_2.total_upvotes).to eql 2

      	expect(User.find(2).point).to eql 8
      	expect(User.find(3).point).to eql 5
      	expect(User.find(4).point).to eql 1


      	put 'api/shouts/'+shout_2.id.to_s, {:token => token, :upvote => false}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ShoutVote.count).to eql 2
      	expect(shout_2.total_upvotes).to eql 0

      	expect(User.find(2).point).to eql 6
      	expect(User.find(3).point).to eql 5
      	expect(User.find(4).point).to eql 1


      	put 'api/shouts/'+shout_2.id.to_s, {:token => token, :upvote => true}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ShoutVote.count).to eql 2
      	expect(shout_2.total_upvotes).to eql 2

      	expect(User.find(2).point).to eql 8
      	expect(User.find(3).point).to eql 5
      	expect(User.find(4).point).to eql 1


      	get 'api/shouts', {:token => token, :order_by => "hot", :page => 0, :per_page => 1}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['shouts'].count).to eql 1
      	expect(JSON.parse(response.body)['data']['shouts'][0]['id']).to eql shout_2.id
      	expect(JSON.parse(response.body)['pagination']['total_count']).to eql 2
      	expect(JSON.parse(response.body)['pagination']['page']).to eql 0
      	expect(JSON.parse(response.body)['pagination']['per_page']).to eql 1

      	BlockUser.create!(origin_user_id: 4, target_user_id: 2)
      	get 'api/shouts', {:token => token, :order_by => "hot"}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['shouts'].count).to eql 1
      	expect(JSON.parse(response.body)['data']['shouts'][0]['id']).to eql shout_3.id
      	BlockUser.delete_all

      	get 'api/shouts', {:token => token, :order_by => "hot"}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['shouts'].count).to eql 2
      	expect(JSON.parse(response.body)['data']['shouts'][0]['id']).to eql shout_2.id

      	post 'api/report_shouts', {:token => token, :report_type_id => 2, :shout_id => shout_3.id}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true

      	token = user_2.generate_token
      	get 'api/shouts', {:token => token, :order_by => "hot", :my_shouts => true}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['shouts'].count).to eql 2

      	post 'api/report_shouts', {:token => token, :report_type_id => 2, :shout_id => shout_3.id}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true



      	token = user_4.generate_token
      	get 'api/shouts', {:token => token, :order_by => "hot"}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['shouts'].count).to eql 1
      	expect(JSON.parse(response.body)['data']['shouts'][0]['id']).to eql shout_2.id
      	expect(ShoutReportHistory.first.all_reporter.count).to eql 2

      	ShoutReportHistory.delete_all
      	post 'api/shout_comments', {:token => token, :body => "EEE", :shout_id => shout_2.id}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ShoutComment.count).to eql 2
      	shout_comment_2 = ShoutComment.last



      	post 'api/report_shout_comments', {:token => token, :report_type_id => 2, :shout_comment_id => shout_comment_1.id}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true

      	get 'api/shout_comments', {:token => token, :shout_id => shout_2.id}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['shout_comments'].count).to eql 1
      	expect(JSON.parse(response.body)['data']['shout_comments'][0]['id']).to eql shout_comment_2.id

      	get 'api/shouts/'+shout_2.id.to_s, {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['shout_comments'].count).to eql 1
      	expect(JSON.parse(response.body)['data']['shout']['id']).to eql shout_2.id
      	expect(JSON.parse(response.body)['data']['shout_comments'][0]['id']).to eql shout_comment_2.id

      	token = user_2.generate_token
      	post 'api/report_shout_comments', {:token => token, :report_type_id => 2, :shout_comment_id => shout_comment_1.id}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true

      	token = user_4.generate_token
      	ShoutReportHistory.delete_all

      	expect(User.find(2).point).to eql 8
      	expect(User.find(3).point).to eql 5
      	expect(User.find(4).point).to eql 3


      	put 'api/shout_comments/'+shout_comment_2.id.to_s, {:token => token, :upvote => true}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ShoutCommentVote.count).to eql 1
      	expect(shout_comment_2.total_upvotes).to eql 1

      	expect(User.find(2).point).to eql 8
      	expect(User.find(3).point).to eql 5
      	expect(User.find(4).point).to eql 4


      	put 'api/shout_comments/'+shout_comment_2.id.to_s, {:token => token, :upvote => false}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ShoutCommentVote.count).to eql 1
      	expect(shout_comment_2.total_upvotes).to eql -1

      	put 'api/shout_comments/'+shout_comment_2.id.to_s, {:token => token, :upvote => true}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ShoutCommentVote.count).to eql 1
      	expect(shout_comment_2.total_upvotes).to eql 1

      	expect(User.find(2).point).to eql 8
      	expect(User.find(3).point).to eql 5
      	expect(User.find(4).point).to eql 4

      	token = user_2.generate_token
      	put 'api/shout_comments/'+shout_comment_2.id.to_s, {:token => token, :upvote => true}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ShoutCommentVote.count).to eql 2
      	expect(shout_comment_2.total_upvotes).to eql 2

      	expect(User.find(2).point).to eql 9
      	expect(User.find(3).point).to eql 5
      	expect(User.find(4).point).to eql 8

      	put 'api/shout_comments/'+shout_comment_2.id.to_s, {:token => token, :upvote => false}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ShoutCommentVote.count).to eql 2
      	expect(shout_comment_2.total_upvotes).to eql 0

      	expect(User.find(2).point).to eql 9
      	expect(User.find(3).point).to eql 5
      	expect(User.find(4).point).to eql 4

      	put 'api/shout_comments/'+shout_comment_2.id.to_s, {:token => token, :upvote => true}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ShoutCommentVote.count).to eql 2
      	expect(shout_comment_2.total_upvotes).to eql 2

      	expect(User.find(2).point).to eql 9
      	expect(User.find(3).point).to eql 5
      	expect(User.find(4).point).to eql 8

      	token = user_4.generate_token

      	get 'api/shout_comments', {:token => token, :shout_id => shout_2.id, :page => 0, :per_page => 1}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(JSON.parse(response.body)['data']['shout_comments'].count).to eql 1
      	expect(JSON.parse(response.body)['data']['shout_comments'][0]['id']).to eql shout_comment_2.id
      	expect(JSON.parse(response.body)['pagination']['total_count']).to eql 2
      	expect(JSON.parse(response.body)['pagination']['page']).to eql 0
      	expect(JSON.parse(response.body)['pagination']['per_page']).to eql 1


      	delete 'api/shout_comments/'+shout_comment_1.id.to_s, {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 403

      	delete 'api/shouts/'+shout_1.id.to_s, {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql false
      	expect(JSON.parse(response.body)['error']['code']).to eql 403


      	delete 'api/shout_comments/'+shout_comment_2.id.to_s, {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(ShoutCommentVote.count).to eql 0
      	expect(ShoutComment.count).to eql 1

      	token = user_2.generate_token
      	delete 'api/shouts/'+shout_2.id.to_s, {:token => token}, {'API-VERSION' => 'V2_0', 'HTTPS' => 'on'}
      	expect(response.status).to eql 200
      	expect(JSON.parse(response.body)['success']).to eql true
      	expect(Shout.count).to eql 2
      	expect(ShoutComment.count).to eql 0
      	expect(ShoutVote.count).to eql 0

      	RecentActivity.delete_all
      	ShoutCommentVote.delete_all
      	ShoutComment.delete_all
      	ShoutVote.delete_all
      	Shout.delete_all
      	ActiveInVenueNetwork.delete_all
      	ActiveInVenue.delete_all
      	Beacon.delete_all
      	Venue.delete_all
      	VenueNetwork.delete_all
	    UserAvatar.delete_all
	    User.delete_all
	end

end
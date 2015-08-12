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

	      	post :sign_up_without_avatar, :email => 'test3@yero.co', :password => '123456', :birthday => 'May 23, 1990', :first_name => 'Test', :gender => 'M'
      		expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql User.last.id

	      	# forget password
			post :forgot_password, :email => 'test4@yero.co'
			expect(response.status).to eql 200
			expect(JSON.parse(response.body)['success']).to eql false
	      	expect(JSON.parse(response.body)['message']).to eql 'The email you have used is not valid.'


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
		    
		    post :login, {email: 'test2@yero.co', password: '123456'}
		    expect(response.status).to eql 200
	      	expect(JSON.parse(response.body)['success']).to eql true
	      	expect(JSON.parse(response.body)['data']['id']).to eql 2

	      	token = JSON.parse(response.body)['data']['token']


	    	# post :show, nil, { 'X-API-TOKEN' => token }
	    	# expect(response.status).to eql 200
	    	# expect(JSON.parse(response.body)['success']).to eql true
	     #  	expect(JSON.parse(response.body)['data']['id']).to eql 2


	    	user_2.destroy
	    end
	end


end

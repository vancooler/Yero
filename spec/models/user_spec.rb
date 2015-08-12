require 'spec_helper'
describe User do

	it {should respond_to :first_name}
	it {should respond_to :gender}
	it {should respond_to :birthday}
	it {should respond_to :user_avatars}



  	let(:user) { create(:user) }
  	# let(:user_2) { create(:user_2) }
  	# let(:active_in_venue) { create(:active_in_venue) }

	describe "test user" do
	    
		context "When first name is missing" do
			before {user.first_name = nil}
			it { should_not be_valid }
		end

		context "When birthday is missing" do
			before {user.birthday = nil}
			it { should_not be_valid }
		end

		context "When gender is missing" do
			before {user.gender = nil}
			it { should_not be_valid }
		end


	    context "ID" do
	      it "ID" do
	        expect(user.id).to eql 1
	      end

	      it "email" do
	        expect(user.email).to eql "test@yero.co"
	      end
	    

	    
	      it "test has_activity_today?" do
	      	venue_network = VenueNetwork.create!(id:1, name: "V")
	      	venue = Venue.create!(id:1, venue_network: venue_network, name: "AAA")
	      	active_in_venue = ActiveInVenue.create!(user_id: 1, venue_id:1)
	      	active_in_venue_network = ActiveInVenueNetwork.create!(user_id: 1, venue_network_id:1)
	        expect(user.has_activity_today?).to eql true
	        expect(user.current_venue).to eql venue
	        expect(user.current_venue_network).to eql venue_network
	        active_in_venue_network.destroy
	        active_in_venue.destroy
	        venue.destroy
	        venue_network.destroy
	      end

	      it "test current_venue" do
	        expect(user.current_venue).to eql nil
	      end

	      it "test current_venue_network" do
	        expect(user.current_venue_network).to eql nil
	      end

	      it "test current_beacon" do
	        expect(user.current_beacon).to eql nil
	      end

	      

	      it "test age" do
	        expect(user.age).to eql 20
	      end

	      it "test name" do
	        expect(user.name).to eql user.first_name+' (1)'
	      end

	      it "ppl" do
	      	user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: (Time.now - 21.years), gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1")
	      	venue_network = VenueNetwork.create!(id:1, name: "V")
	      	venue = Venue.create!(id:1, venue_network: venue_network, name: "AAA")
	      	active_in_venue = ActiveInVenue.create!(user_id: 1, venue_id:1)
	      	active_in_venue_2 = ActiveInVenue.create!(user_id: 2, venue_id:1)
	      	ua = UserAvatar.create!(user: user_2, default: true, order: 0)
	      	wt = WhisperSent.create!(target_user_id: 2, origin_user_id: 1, whisper_time: Time.now)
	        expect(user.same_venue_as?(2)).to eql true
	        expect(user.different_venue_as?(2)).to eql false
	        expect(user.fellow_participants(nil, 19, 50, nil, 0, 1000, true).length).to eql 1
	        expect(user.fellow_participants(nil, 19, 50, nil, 0, 1000, false).length).to eql 1
	        expect(user.fellow_participants('F', 19, 50, nil, 1, 1000, false).length).to eql 1
	        expect(user.people_list(3, 'F', 19, 40, nil, 1, 100, true, 0, 48)['users'].count).to eql 1
	        expect(user.same_venue_users([user_2])).to eql [user_2]
	        expect(user.distance_label(user_2)).to eql "Within 10km"
	        expect(user.actual_distance(user_2)).to eql 7.252281031416336
	        active_in_venue.destroy
	        active_in_venue_2.destroy
	        venue.destroy
	        venue_network.destroy
	        ua.destroy
	        user_2.destroy
	        wt.destroy
	      end


	      it "to_json" do
	      	birthday = (Time.now - 21.years)
	      	user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: birthday, gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", snapchat_id: "snapchat_id", instagram_id: "instagram_id", wechat_id: nil, line_id: "line_id", introduction_1: "introduction_1", discovery: false, exclusive: false, is_connected: true, current_city: "Vancouver", timezone_name: "America/Vancouver")
	      	venue_network = VenueNetwork.create!(id:1, name: "V", timezone: "America/Vancouver")
	      	venue = Venue.create!(id:1, venue_network: venue_network, name: "AAA")
	      	beacon = Beacon.create!(key: "Vancouver_TestVenue_test", venue_id: 1)
	      	active_in_venue = ActiveInVenue.create!(user_id: 2, venue_id:1)
	      	ua = UserAvatar.create!(id: 1, user: user_2, is_active: true, order: 0)
	      	ua_2 = UserAvatar.create!(id: 2, user: user_2, is_active: true, order: 1)
	      	NotificationPreference.create!(name: "Network online")
			NotificationPreference.create!(name: "Enter venue network")
			NotificationPreference.create!(name: "Leave venue network")
			UserNotificationPreference.update_preferences_settings(user_2, true, true, true)
	      	expect(user_2.to_json(true)["id"]).to eql 2
	      	expect(user_2.to_json(true)["birthday"].to_date).to eql birthday.to_date
	      	expect(user_2.to_json(true)["first_name"]).to eql "SF"
	      	expect(user_2.to_json(true)["email"]).to eql "test2@yero.co"
	      	expect(user_2.to_json(true)["snapchat_id"]).to eql 'snapchat_id'
	      	expect(user_2.to_json(true)["wechat_id"]).to eql ''
	      	expect(user_2.to_json(true)["line_id"]).to eql 'line_id'
	      	expect(user_2.to_json(true)["instagram_id"]).to eql 'instagram_id'
	      	expect(user_2.to_json(true)["discovery"]).to eql false
	      	expect(user_2.to_json(true)["exclusive"]).to eql false
	      	expect(user_2.to_json(true)["joined_today"]).to eql true
	      	expect(user_2.to_json(true)["key"]).to eql "1"
	      	expect(user_2.to_json(true)["current_venue"]).to eql "TestVenue"
	      	expect(user_2.to_json(true)["current_city"]).to eql "Vancouver"
	      	expect(user_2.to_json(true)["avatars"][0]['order']).to eql 0
	      	expect(user_2.to_json(true)["notification_preferences"].length).to eql 3
	      	expect(user_2.to_json(true)["notification_preferences"][0]["type"]).to eql "Network online"
	      	expect(user_2.to_json(true)["notification_preferences"][0]["enabled"]).to eql false
			expect(user_2.to_json(true)["notification_preferences"][1]["type"]).to eql "Enter venue network"
	      	expect(user_2.to_json(true)["notification_preferences"][1]["enabled"]).to eql false
	      	expect(user_2.to_json(true)["notification_preferences"][2]["type"]).to eql "Leave venue network"
	      	expect(user_2.to_json(true)["notification_preferences"][2]["enabled"]).to eql true
	        expect(user_2.main_avatar.id).to eql 1
	        expect(user_2.default_avatar.id).to eql 1
	        expect(user_2.secondary_avatars.first.id).to eql 2
	      	
	      	user_2.avatar_reorder([2, 1])
	      	expect(user_2.to_json(true)["avatars"][0]['avatar_id']).to eql 2
	      	expect(user_2.to_json(true)["avatars"][1]['avatar_id']).to eql 1

	      	user_2.leave_network
	      	expect(user_2.to_json(true)["joined_today"]).to eql false

	      	user_2.join_network
	      	expect(user_2.to_json(true)["joined_today"]).to eql true
	      	WhisperToday.create(target_user_id: 2, origin_user_id: 1, whisper_type: "2")
	      	User.handle_close(["America/Vancouver"])

	      	expect(RecentActivity.all.count).to eql 2
	      	expect(WhisperNotification.my_chat_request_history(user_2, 0, 5).count).to eql 2
	      	expect(WhisperToday.all.count).to eql 0
	      	expect(ActiveInVenue.all.count).to eql 0


	      	RecentActivity.destroy_all
	      	active_in_venue.destroy
	      	venue_network.destroy
	        venue.destroy
	        beacon.destroy
			UserNotificationPreference.update_preferences_settings(user, false, false, false)
			NotificationPreference.destroy_all
	      	ua.destroy
	      	ua_2.destroy
	      	expect(user_2.to_json(true)["avatars"]).to eql []
	        user_2.destroy
	      end

	      # it "same_beacon_as?" do
	      #   expect(user.same_beacon_as?(2)).to eql false
	      # end
	    end
	end




end
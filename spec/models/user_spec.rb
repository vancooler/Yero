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

	      it "test main_avatar" do
	        expect(user.main_avatar).to eql nil
	      end

	      it "test secondary_avatars" do
	        expect(user.secondary_avatars.blank?).to eql true
	      end

	      it "test age" do
	        expect(user.age).to eql 20
	      end

	      it "test name" do
	        expect(user.name).to eql user.first_name+' (1)'
	      end

	      it "same_venue_as?" do
	      	user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: (Time.now - 21.years), gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1")
	      	venue_network = VenueNetwork.create!(id:1, name: "V")
	      	venue = Venue.create!(id:1, venue_network: venue_network, name: "AAA")
	      	active_in_venue = ActiveInVenue.create!(user_id: 1, venue_id:1)
	      	active_in_venue_2 = ActiveInVenue.create!(user_id: 2, venue_id:1)
	      	ua = UserAvatar.create!(user: user_2, default: true, order: 0)
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
	      end

	      

	      # it "same_beacon_as?" do
	      #   expect(user.same_beacon_as?(2)).to eql false
	      # end
	    end
	end




end
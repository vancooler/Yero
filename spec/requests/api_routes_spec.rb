# require 'spec_helper'

# # # API_TEST_BASE_URL = "http://purpleoctopus-staging.herokuapp.com"
# # API_TEST_BASE_URL = "http://localhost:3000"

# describe 'API' do
#   describe 'Registration' do
    
#     let (:avatar_path) {'/home/alex/sites/yero/purpleoctopus-staging/spec/files/sample_avatar.jpg'}
    
#     describe 'submits the appropriate age, name, gender and avatar' do
#       user_count = User.count
#       before do
#         post '/api/v1/users/signup',
#         { :user => {
#                 :first_name => 'Maria',
#                 :gender => 'F',
#                 :birthday => Date.today - 20.years,
#                 :user_avatars_attributes =>{
#                   "0"=> {:avatar=> File.new(avatar_path, 'rb')}
#                 }
#               }

#         }
#       end

#       let(:response_to_client) {JSON.parse(response.body, symbolize_names: true)}
#       let(:user) { User.find(response_to_client[:data][:id]) }

#       it { expect(response).to be_success }
#       it { expect(User.count).to be(user_count+1) }
#       it { expect(user.user_avatars.count).to be(1) }
#       it { expect(response_to_client[:success]).to be(true) } #this feature is not neccesary, it should have been checked with status code
#       it { expect(user.user_avatars.count).to be(1) }

#       it 'should reject registration with age less than 19'
#       it 'should reject registration without an avatar'
#       it 'should reject registration without a birthday'
#       it 'should reject registration without a gender'
#     end

#   end
#   describe 'Beacons' do
#     let(:venue_network) {FactoryGirl.create(:venue_network)}

#     let(:user) {FactoryGirl.create(:user)}
    


#     context "There are users in two different venues, and user requests a user list.." do
#       let(:his_buddy) { FactoryGirl.create(:user_with_avatar, first_name: "His Buddy", gender: "M")}
#       let(:cutie)     { FactoryGirl.create(:user_with_avatar, first_name: "Cutie",     gender: "F")}
#       let(:her_bff)   { FactoryGirl.create(:user_with_avatar, first_name: "Her BFF",   gender: "F")}

#       let(:venue_type) {FactoryGirl.create(:venue_type)}
      
#       # first venue
#       let(:venue_1)   {FactoryGirl.create(:venue, venue_network: venue_network, name: 'Aubar', venue_type: venue_type)}
#       let(:dance_room){FactoryGirl.create(:room, venue: venue_1, name: 'Dance')}
#       let(:beacon_1a) {FactoryGirl.create(:beacon, room: dance_room, key: 'Vancouver_Aubar_Dance_01_123')}
#       let(:beacon_1b) {FactoryGirl.create(:beacon, room: dance_room, key: 'Vancouver_Aubar_Dance_02_456')}

#       # second venue
#       let(:venue_2)   {FactoryGirl.create(:venue, venue_network: venue_network, name: 'Republic', venue_type: venue_type)}
#       let(:room_vip)  {FactoryGirl.create(:room, venue: venue_2, name: 'VIP')}
#       let(:beacon_2a) {FactoryGirl.create(:beacon, room: room_vip, key: 'Vancouver_Republic_VIP_01_789')}

#       before do
#         post 'api/v1/room/enter', {key: his_buddy.key, beacon_key: beacon_1b.key} 
#         # puts '-'*100
#         # puts his_buddy.inspect
#         # puts beacon_1b.room.inspect
#         # puts beacon_1b.room.venue.inspect
#         # puts "Buddy Entered..#{beacon_1b.inspect}"
#         # puts "*"*100
#         # puts ""
#         # puts '-'*100
#         post 'api/v1/room/enter', {key: cutie.key,     beacon_key: beacon_2a.key} 
#         # puts cutie.inspect
#         # puts "Cutie Entered..#{beacon_2a.inspect}"
#         # puts beacon_2a.room.inspect
#         # puts beacon_2a.room.venue.inspect
#         # puts "*"*100
#         # puts ""
#         post 'api/v1/room/enter', {key: her_bff.key,   beacon_key: beacon_2a.key} 
#         # puts her_bff.inspect
#         # puts "her bff Entered.."
#         # puts ""
#       end
      
#       describe "the user didnt enter the network yet.." do
#         before do
#           post 'api/v1/users',{key: user.key}
#         end

#         let(:response_to_client) {JSON.parse(response.body, symbolize_names: true)}

#         it { expect(response).to be_success }
#         it { expect(response_to_client[:success]).to be(true)}
#         it "should not have any users in his list" do
#           expect(response_to_client[:users].count).to be(0)
#         end
#       end

#       describe "the user enters a venue the same as his buddy (through a different beacon in the venue).." do
#         before do
#          post 'api/v1/room/enter', {key: his_buddy.key,   beacon_key: beacon_1b.key} 
#          post 'api/v1/room/enter', {key: user.key,        beacon_key: beacon_1a.key} 
#          post 'api/v1/users',      {key: user.key} 
#        end
        
#         let(:response_to_client) {JSON.parse(response.body, symbolize_names: true)}

#         it { expect(response).to be_success }
#         it { expect(response_to_client[:success]).to be(true)}
#         it "should not have 3 users in his list" do
#           expect(response_to_client[:users].count).to be(3)
#         end
#         it "should show that his buddy has a badge" do
#           response_to_client[:users].each do |user_hash|
#             if user_hash[:id] == his_buddy.id
#               expect(user_hash[:same_venue_badge]).to be(true) 
#             end
#           end
#         end

#         it "should show that all users in other venues without a badge" do
#           users_in_other_venues = []
#           response_to_client[:users].each do |user_hash|
#             users_in_other_venues << user_hash unless user_hash[:id] == his_buddy.id
#           end
#           expect(users_in_other_venues.first[:same_venue_badge]).to be(false) 
#           expect(users_in_other_venues.last[:same_venue_badge]).to be(false) 
#         end

#         describe "the user exits the venue.." do
#           before do
#             post 'api/v1/room/leave', {key: user.key, beacon_key: beacon_1a.key} 
#             post 'api/v1/users',      {key: user.key} 
#           end

#           let(:response_to_client) {JSON.parse(response.body, symbolize_names: true)}

#           it { expect(response).to be_success }
#           it { expect(response_to_client[:success]).to be(true)}
#           it "should show 3 users" do
#             expect(response_to_client[:users].count).to be(3) 
#           end
#           it "should not show any bades in the user list" do
#             badge_booleans = []
#             response_to_client[:users].each do |user_hash|
#               badge_booleans << user_hash[:same_venue_badge]
#             end
#             badge_booleans.uniq!
#             expect(badge_booleans.count).to be(1)
#             expect(badge_booleans[0]).to be(false)
#           end
#         end

#         describe "his buddy leaves the venue through the beacon he entered.." do
#           before do
#             post 'api/v1/room/leave', {key: his_buddy.key,        beacon_key: beacon_1b.key} 
#             post 'api/v1/users',{key: user.key}
#           end

#           let(:response_to_client) {JSON.parse(response.body, symbolize_names: true)}

#           it { expect(response).to be_success }
#           it { expect(response_to_client[:success]).to be(true)}
#           it "should still have 3 users in his list" do
#             expect(response_to_client[:users].count).to be(3)
#           end
#           it "should show no badges in his list" do
#             badge_booleans = []
#             response_to_client[:users].each do |user_hash|
#               badge_booleans << user_hash[:same_venue_badge]
#             end
#             badge_booleans.uniq!
#             expect(badge_booleans.count).to be(1)
#             expect(badge_booleans[0]).to be(false)
#           end
#         end
#         describe "his buddy leaves the venue through a different beacon.." do
#           before do
#             post 'api/v1/room/leave', {key: his_buddy.key,        beacon_key: beacon_1a.key} 
#             post 'api/v1/users',{key: user.key}
#           end
          
#           let(:response_to_client) {JSON.parse(response.body, symbolize_names: true)}

#           it { expect(response).to be_success }
#           it { expect(response_to_client[:success]).to be(true)}
#           it "should still have 3 users in his list" do
#             expect(response_to_client[:users].count).to be(3)
#           end
#           it "should show no badges in his list" do
#             badge_booleans = []
#             response_to_client[:users].each do |user_hash|
#               badge_booleans << user_hash[:same_venue_badge]
#             end
#             badge_booleans.uniq!
#             expect(badge_booleans.count).to be(1)
#             expect(badge_booleans[0]).to be(false)
#           end
#         end
#       end

#       describe "the user enters the second venue" do
#         it "should show the user other participants"
#         it "should show the user badges of the people in his current venue"
#         it "should show the users in the current venue first"
#       end
#       describe "everyone leaves their venues" do
#         it "should show a list of participants"
#         it "should not show any badges in the users list"
#       end

#     end

#   end

#   describe 'User Profile' do
    
#     let (:avatar_path) {'/home/alex/sites/yero/purpleoctopus-staging/spec/files/sample_avatar.jpg'}
#     let!(:user) {FactoryGirl.create(:user)}

#     describe "Existing user uploads a new avatar" do
#       before do
#         post 'api/v1/avatar/create', 
#         {
#           key: user.key, 
#           avatar: File.new(avatar_path, 'rb')
#         }
#       end

#       let(:response_to_client) {puts JSON.parse(response.body, symbolize_names: true)}

#       it { expect(response).to be_success }
#       it { expect(user.user_avatars.count).to be(1) }
#       it { expect(user.user_avatars.first.default).to be(true) }
#     end

#     describe "Existing user uploads a avatar set to default " do
      
#       before do
#         post 'api/v1/avatar/create',
#         {
#           key: user.key,
#           avatar: File.new(avatar_path, 'rb'),
#           default: true
#         }
#       end

#       let(:response_to_client) {JSON.parse(response.body, symbolize_names: true)}

#       it { expect(response).to be_success }
#       it { expect(response_to_client[:success]).to be(true) }
#       it { expect(user.user_avatars.count).to be(1) }
      
#       describe "uploads a second avatar, without setting to default.." do
#         before do
#           post 'api/v1/avatar/create',
#           {
#             key: user.key,
#             avatar: File.new(avatar_path, 'rb')
#           }
#         end
#         it { expect(response).to be_success }
#         it { expect(response_to_client[:success]).to be(true) }
#         it { expect(user.user_avatars.last.default).to be(false) }
#         it { expect(user.user_avatars.first.default).to be(true) }
#         it { expect(user.user_avatars.count).to be(2) }
#         it { expect(user.user_avatars.where(default:true).count).to be(1) }

#         describe "sets a non-default existing avatar to default.." do
#           before do
#             post 'api/v1/avatar/set_default',
#             {
#               key: user.key,
#               avatar_id: user.user_avatars.last.id
#             }
#           end

#           it { expect(response).to be_success }
#           it { expect(response_to_client[:success]).to be(true) }
#           it { expect(user.user_avatars.last.default).to be(true) }
#           it { expect(user.user_avatars.first.default).to be(false) }
#           it { expect(user.user_avatars.count).to be(2) }
#           it { expect(user.user_avatars.where(default:true).count).to be(1) }

#           describe "tries to delete the default avatar.. unsuccessfully" do
#             before do
#               post 'api/v1/avatar/destroy',
#               {
#                 key: user.key,
#                 avatar_id: user.user_avatars.find_by(default:true).id
#               }
#             end
#             it { expect(response).to be_success }
#             it { expect(response_to_client[:success]).to be(false) }
#             it { expect(user.user_avatars.count).to be(2) }
#             it { expect(user.user_avatars.where(default:true).count).to be(1) }
#           end

#           describe "uploads a third avatar" do
#             before do
#               post 'api/v1/avatar/create',
#               {
#                 key: user.key,
#                 avatar: File.new(avatar_path, 'rb')
#               }
#             end
#             it { expect(response).to be_success }
#             it { expect(response_to_client[:success]).to be(true) }
#             it { expect(user.user_avatars.count).to be(3) }
#             it { expect(user.user_avatars.where(default:true).count).to be(1) }

#             describe "tries to upload a fourth avatar" do
#               before {post 'api/v1/avatar/create',{key:user.key, avatar: File.new(avatar_path, 'rb')}}
#               it { expect(response).to be_success }
#               it { expect(response_to_client[:success]).to be(false) }
#               it { expect(user.user_avatars.count).to be(3) }
#               it { expect(user.user_avatars.where(default:true).count).to be(1) }

#               describe "tries to delete all avatars" do
#                 before do
#                   user.user_avatars.each do |avatar|
#                     post 'api/v1/avatar/destroy',{key: user.key, avatar_id: avatar.id}
#                   end
#                 end
#                 it { expect(user.user_avatars.count).to be(1) }
#                 it { expect(user.user_avatars.where(default:true).count).to be(1) }
#                 it { expect(user.user_avatars.first.default).to be(true) }
#               end
#             end
#           end
#         end
#       end
#     end

#     context "User has an avatar.." do
      
#       let (:user) { FactoryGirl.create(:user_with_avatar)}

#       describe "User requests to view his own profile" do
#         before {post '/api/v1/user/show', {key: user.key }}
#         let(:response_to_client) {JSON.parse(response.body, symbolize_names: true)}

#         # it { expect(response).to be_success }
#         # it { expect(response_to_client[:success]).to be(true) }
#         it "should poop" do
#           puts user.inspect, user.user_avatars.count, "::::" 
#         end
#       end

#       describe "User updates introduction line 1 of her profile" do
#         before do
#           post '/api/v1/user/update_profile', {key: user.key, introduction_1: "Intro 1"}
#           post '/api/v1/user/show', {key: user.key }
#         end
#         let(:response_to_client) {JSON.parse(response.body, symbolize_names: true)}

#         it { expect(response).to be_success }
#         it { expect(response_to_client[:success]).to be(true) }
#         it { expect(response_to_client[:data][:introduction_1]).to be("Intro 1")}
#       end

#       describe "User updates introductino line 2 of his profile" do
#         before do
#           post '/api/v1/user/update_profile', {key: user.key, introduction_2:"Intro 2"}
#           post '/api/v1/user/show', {key: user.key }
#         end
#         let(:response_to_client) {JSON.parse(response.body, symbolize_names: true)}

#         it { expect(response).to be_success }
#         it { expect(response_to_client[:success]).to be(true) }
#         it { expect(response_to_client[:data][:introduction_2]).to be("Intro 2")}
#       end

#       describe "User updates both lines at the same time" do
#         before do
#           post '/api/v1/user/update_profile', {key: user.key, introduction_1: "Intro 1", introduction_2:"Intro 2"}
#           post '/api/v1/user/show', {key: user.key }
#         end
#         let(:response_to_client) {JSON.parse(response.body, symbolize_names: true)}

#         it { expect(response).to be_success }
#         it { expect(response_to_client[:success]).to be(true) }
#         it { expect(response_to_client[:data][:introduction_1]).to be("Intro 1")}
#         it { expect(response_to_client[:data][:introduction_2]).to be("Intro 2")}
#       end
#     end

#   end
# #   describe "User changes his default avatar" do
# #     before do
# #       # @user = UserRegistration.new(first_name: "Bob", gender: "male", birthday:Time.now - 22.years)
# #       # @user = @user.create
# #       @user = User.last
      
# #       3.times {avatar = @user.user_avatars.create; avatar.save}
      
# #       @default_avatar = @user.user_avatars.find_by(default:true)
# #       @default_avatar_id = @default_avatar.id

# #       @other_avatars = @user.user_avatars.where.not(default:true)
# #       @new_default_id = @other_avatars.first.id
# #       @response = RestClient.post("#{API_TEST_BASE_URL}/api/v1/avatar/set_default",
# #           {
# #             key: @user.key,
# #             avatar_id: @new_default_id
# #           }
# #         )
# #     end
    
# #     it "Should have a response code of 200" do
# #       expect(@response.code).to be == 200
# #     end
# #     it "Should have only 1 default avatar" do
# #       expect(@user.user_avatars.where(default:true).count).to be == 1
# #     end
# #     it "Should have the old default avatar set to false" do
# #       expect(@user.user_avatars.find_by(id: @default_avatar_id).default).to be == false
# #     end
# #     it "Should have the new default set to true" do
# #       expect(UserAvatar.find(@new_default_id).reload.default).to be == true
# #     end
# #   end
# #   describe "Existing user uploads another avatar(/api/v1/users/avatar/add)" do
# #     before do
# #       @avatar_path = '/home/alex/sites/yero/purpleoctopus-staging/spec/files/sample_avatar.jpg'
# #       @add_avatar_url = "#{API_TEST_BASE_URL}/api/v1/avatar/create"
# #       @user = User.last
# #       @initial_avatar_count = @user.user_avatars.count
# #       @response =  RestClient.post( @add_avatar_url,
# #                       {
# #                         key: @user.key,
# #                         avatar: File.new(@avatar_path, 'rb')
# #                       }
# #                     )

# #     end

# #     it { expect(@response.code).to be == 200 }

# #     it "should add a second avatar to the user" do
# #       expect(@user.user_avatars.count).to be == ( @initial_avatar_count + 1 )
# #     end
# #     it "the last avatar should be not default" do
# #       expect(@user.user_avatars.last.default).to be == false
# #     end
# #   end

# #   # describe "Client removes avatar from profile (/api/users/avatar/remove_avatar)" do
# #   #   before do
# #   #     @remove_avatar_path = "#{API_TEST_BASE_URL}/api_v1_users_avatar_remove_avatar"
# #   #     @add_avatar_url = "#{API_TEST_BASE_URL}/api/v1/users/avatar/add"
# #   #     @avatar_path = '/home/alex/sites/yero/purpleoctopus-staging/spec/files/sample_avatar.jpg'
# #   #     @add_avatar_url = "#{API_TEST_BASE_URL}/api/v1/users/avatar/add"
# #   #     @user = User.last
# #   #     @response =  RestClient.post( @add_avatar_url,
# #   #               {
# #   #                 key: @user.key,
# #   #                 avatar: File.new(@avatar_path, 'rb')
# #   #               }
# #   #             )
# #   #     @response =  RestClient.post( @add_avatar_url,
# #   #               {
# #   #                 key: @user.key,
# #   #                 avatar: File.new(@avatar_path, 'rb')
# #   #               }
# #   #             )
# #   #     @initial_avatar_count = @user.user_avatars.count
# #   #     @avatar_path = '/home/alex/sites/yero/purpleoctopus-staging/spec/files/sample_avatar.jpg'

# #   #   end
# #   #   describe "Should not be able to remove the last avatar" do
# #   #     before do
# #   #       @remove_avatar_path = "#{API_TEST_BASE_URL}/api_v1_users_avatar_remove_avatar"
# #   #       @user = User.last
# #   #       @user.user_avatars.each do |avatar|
# #   #         @response =  RestClient.post( @remove_avatar_path,
# #   #                             {
# #   #                               key: @user.key,
# #   #                               avatar_id: avatar.id
# #   #                             }
# #   #                           )
# #   #       end
# #   #       it "Should return an error" do
# #   #         expect(JSON.parse(@response)["success"]).to be == "false"
# #   #       end
# #   #       it "The user should have 1 avatar left" do

# #   #       end
# #   #       it "the user's avatar should be default" do
# #   #         expect(JSON.parse(@user.user_avatars.count)).to be == 1
# #   #       end
# #   #     end

# #   #   end
# #   #   it "Should be able to remove the first avatar, and that automatically sets the last avatar to default" do

# #   #   end
# #   #   it "Should not be able to remove the last avatar" do

# #   #   end
# #   # end

# #   # describe "YJ Test" do

# #   #  # @response = RestClient.post( "http://localhost:3000/api/v1/room/enter",
# #   #  @response = RestClient.post( "http://purpleoctopus-staging.herokuapp.com/api/v1/room/enter",
# #   #                           {
# #   #                             key: "_OUMSy4dmSXTugIk9-HVWg",
# #   #                             beacon_key: "YJ-02-Vancouver-039MNB",
# #   #                             temperature: "23"
# #   #                           }
# #   #                         )

# #   #   # @response = RestClient.post( "http://localhost:3000/api/v1/room/leave",
# #   #   @response = RestClient.post( "http://purpleoctopus-staging.herokuapp.com/api/v1/room/leave",
# #   #                           {
# #   #                             key: "2NihILTlrZ7idzwOzg3TRA",
# #   #                             beacon_key: "bacon-beacon",
# #   #                             # temperature: ((10...40).to_a).sample
# #   #                           }
# #   #                         )
# #   # end

# #   describe "Server gets a notification of a client enters a beacon (/api/room/enter)" do

# #     before do
# #       @user = User.last
# #       @room = Room.last
# #       @beacon = @room.beacons.last
# #       @venue = @room.venue

# #       #emulate sending request from phone of entering a beacon
# #       @response = RestClient.post( "#{API_TEST_BASE_URL}/api/v1/room/enter",
# #                           {
# #                             key: @user.key,
# #                             beacon_key: @beacon.key,
# #                             temperature: ((10...40).to_a).sample
# #                           }
# #                         )

# #     end
# #     it "Should create a new participant for the room with the correct room/user id" do
# #       expect(@room.id).to be == Participant.last.room_id
# #       expect(@user.id).to be == Participant.last.user_id
# #     end
# #     it "Should return data of room id, and user to the phone ?"
# #     it "Should have a response code of 200" do
# #       expect(@response.code).to be == 200
# #     end

# #   end

# #   describe "Server gets a notification of a client exits a beacon (/api/room/leave)" do
# #     before do
# #       @user = User.last
# #       @room = Room.last
# #       @beacon = @room.beacons.last
# #       @venue = @room.venue
# #       RestClient.post( "#{API_TEST_BASE_URL}/api/v1/room/enter",
# #                           {
# #                             key: @user.key,
# #                             beacon_key: @beacon.key
# #                           }
# #                         )

# #       @response = RestClient.post( "#{API_TEST_BASE_URL}/api/v1/room/leave",
# #                           {
# #                             key: @user.key,
# #                             beacon_key: @beacon.key
# #                           }
# #                         )
# #     end
# #     it "Should have a response code of 200" do
# #       expect(@response.code).to be == 200
# #     end
# #     it "Should not be able to find a participant with the submitted room and user id" do
# #       expect(Participant.where(user_id: @user.id, room_id: @room.id).count).to be == 0
# #     end
# #   end

# #   describe "Server gets a request for the venue list (/api/venues/list)" do
# #     before do
# #       @user = User.last
# #       @response = RestClient.get( "#{API_TEST_BASE_URL}/api/v1/venues/list",
# #                             params:{
# #                               key: @user.key
# #                             }
# #                           )
# #     end
# #     it "returns all venues in the app" do
# #       expect(JSON.parse(@response)["data"].count).to be == Venue.all.count
# #     end
# #     it "Should have a response code of 200" do
# #       expect(@response.code).to be == 200
# #     end
# #     it "Should return venues in the current users's network only?"
# #     it "Should return venues between certain times?"
# #     it "Should return different attributes during the night?"
# #     it "Should return different attributes if the user is 'out'?"
# #   end

# #   describe "Client requests the user profile" do
# #     before do
# #       #create user
# #       #request profiles for current user token
# #     end
# #     it "Should return the profile (/api/profile)" do

# #     end
# #   end

# #   describe "Client sends the server new profile information (/api/users/update)" do
# #     before do
# #       #create user
# #       # create user profile
# #     end
# #     it "Should change the user information in the server" do

# #     end
# #     it "Should return success" do

# #     end
# #     it "Should update the user profile" do

# #     end
# #   end

# #   describe "Client sends the server gps location to calculate distance between users" do
# #     before do
# #       @user = User.last
# #       Geocoder.coordinates("25 Main St, Cooperstown, NY")
# #       @user_locations_count = @user.locations.count
# #       @response = RestClient.post( "#{API_TEST_BASE_URL}/api/v1/user/locations/new",
# #                               key: @user.key,
# #                               latitude: Geocoder.coordinates("Republic, Vancouver")[0],
# #                               longitude: Geocoder.coordinates("Republic, Vancouver")[1]
# #                           )
# #     end
# #     it "should create a location for the user" do
# #       expect(@user.locations.count).to be == (@user_locations_count + 1)
# #     end
# #   end

# #   describe "Request a list of people in a venue" do
# #     before do
# #       # initialize 3 beacons for the same venue
# #       beacons = []
# #       %w[Vancouver_Republic_bar-downstairs_01_001CFG 
# #          Vancouver_Republic_bar-downstairs_02_002EZY 
# #          Vancouver_Republic_bar-upstairs_01_001KEK].each do |beacon|
# #           beacon = BeaconInitialization.new(beacon)
# #           beacon = beacon.create
# #           beacons << beacon
# #       end

# #       @venue = Venue.last

# #       # enter and exit a bunch of users
# #       User.all.each do |user|
# #         #enter user
# #          @response = RestClient.post( "http://localhost:3000/api/v1/room/enter",
# #                           {
# #                             key: user.key,
# #                             beacon_key: beacons.sample.key,
# #                             temperature: "24"
# #                           }
# #                         )
# #         if [true,false].sample
# #           # Exit half of the users
# #            @response = RestClient.post( "http://localhost:3000/api/v1/room/leave",
# #                   {
# #                     key: user.key,
# #                     beacon_key: beacons.sample.key,
# #                     temperature: "24"
# #                   }
# #                 )
# #         end
# #       end #User.all.each..
# #       # RestClient.post("#{API_TEST_BASE_URL}api/v1/users",
# #       # RestClient.post("http://localhost:3000/api/v1/users",
# #       RestClient.post("http://localhost:3000/api/v1/users",
# #       # RestClient.post("http://purpleoctopus-staging.herokuapp.com/api/v1/users",
# #         key: User.last.key
# #         )
# #       # RestClient.post("http://purpleoctopus-staging.herokuapp.com/api/v1/users",
# #       #   key: "sDWN0YLdHmz-9vILcJuKow",
# #       #   venue_id: "4"
# #       #   )
# #     end
# #     it "Should return a list of users" do

# #     end
# #   end

# #   # describe "Lottery" do
# #   #   before do
# #   #     # create venue accounts
# #   #     # create 3 venues
# #   #     # create 10 users per venues
# #   #     # enter them via beaon call, and convert them into participants
# #   #   end
# #   #   describe "Venue logs in and clicks on lottery" do
# #   #     # enter login credentials
# #   #     it "should see a list of 10 participants in the venue" do

# #   #     end

# #   #     describe "Venue clicks selects a prize and draws a winner" do
# #   #       before do
# #   #         # click on lottery button
# #   #         # set the prize
# #   #       end
# #   #       it "should select a winner" do

# #   #       end
# #   #       it "should send the user a push notification and recieve that the push was pushed" do

# #   #       end
# #   #       it "should show the client the prize" do

# #   #       end
# #   #     end
# #   #   end
# #   # end 

# #   # describe "client adds a venue to his favorites" do

# #   # end

# #   # describe "client removes a venue from his favorites" do

# #   # end

# #   # describe "user views a list of his favorite venues" do

# #   # end

# #   # describe "clients sees a list of his favorite venues" do

# #   # end

# end

# #   # TODO
# # # /apn/[user_id, data, resource, apn_key]
# # # /api/lottery/show

# # # what is claim?

# # # why do you need to update the apn??
# # # /api/users/update-apn

# # # /api/users/add_favorite_venue
# # # /api/users/remove_favorite_venue


# # # /api/venues/people --- current venue people

# # # /api/apn/from_user_token, to_user_token, apn_token, 

# # # /
# # # network/disconnect [user_token, network_id] 


# # # api/history/[resource, data]^


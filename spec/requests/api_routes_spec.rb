require 'spec_helper'

describe 'API' do

  describe "Registration (/api/v1/users/signup)" do
    before do
      @user_count = User.count
      # @base_url = 'http://4635554.ngrok.com'
      @base_url = API_TEST_BASE_URL
      @signup_url = @base_url+'/api/v1/users/signup'
      @avatar_path = '/home/alex/sites/yero/purpleoctopus-staging/spec/files/sample_avatar.jpg'
      @response =  RestClient.post( @signup_url,
                            {
                              :user => {
                                :first_name => 'Maria',
                                :gender => 'F',
                                :birthday => Date.today - 20.years,
                                :user_avatars_attributes =>{
                                  "0"=> {:avatar=> File.new(@avatar_path, 'rb')}
                                }
                              }
                            }
                          )
    end

    
    it "Should have a response code of 200" do
      expect(@response.code).to be == 200
    end
    it "Should create a user from a post request." do
      expect(User.count).to be == @user_count + 1
    end
    it "Should make a user with have an avatar." do
      expect(User.last.user_avatars.count).to be == 1
    end
    it "Should have an avatar with the default set to true" do
      expect(User.last.user_avatars.last.default).to be == true
    end
  end

  describe "Existing user uploads another avatar(/api/v1/users/avatar/add)" do
    before do
      @avatar_path = '/home/alex/sites/yero/purpleoctopus-staging/spec/files/sample_avatar.jpg'
      @add_avatar_url = "#{API_TEST_BASE_URL}/api/v1/users/avatar/add"
      @user = User.last
      @initial_avatar_count = @user.user_avatars.count
      @response =  RestClient.post( @add_avatar_url,
                      {
                        key: @user.key,
                        avatar: File.new(@avatar_path, 'rb')
                      }
                    )

    end

    it { expect(@response.code).to be == 200 }

    it "should add a second avatar to the user" do
      expect(@user.user_avatars.count).to be == ( @initial_avatar_count + 1 )
    end
    it "the last avatar should be not default" do
      expect(@user.user_avatars.last.default).to be == false
    end
  end

  describe "Client removes avatar from profile (/api/users/avatar/remove_avatar)" do
    before do
      @remove_avatar_path = "#{API_TEST_BASE_URL}/api_v1_users_avatar_remove_avatar"
      @add_avatar_url = "#{API_TEST_BASE_URL}/api/v1/users/avatar/add"
      @avatar_path = '/home/alex/sites/yero/purpleoctopus-staging/spec/files/sample_avatar.jpg'
      @add_avatar_url = "#{API_TEST_BASE_URL}/api/v1/users/avatar/add"
      @user = User.last
      @response =  RestClient.post( @add_avatar_url,
                {
                  key: @user.key,
                  avatar: File.new(@avatar_path, 'rb')
                }
              )
      @response =  RestClient.post( @add_avatar_url,
                {
                  key: @user.key,
                  avatar: File.new(@avatar_path, 'rb')
                }
              )
      @initial_avatar_count = @user.user_avatars.count
      @avatar_path = '/home/alex/sites/yero/purpleoctopus-staging/spec/files/sample_avatar.jpg'

    end
    describe "Should not be able to remove the last avatar" do
      before do
        @remove_avatar_path = "#{API_TEST_BASE_URL}/api_v1_users_avatar_remove_avatar"
        @user = User.last
        @user.user_avatars.each do |avatar|
          @response =  RestClient.post( @remove_avatar_path,
                              {
                                key: @user.key,
                                avatar_id: avatar.id
                              }
                            )
        end
        it "Should return an error" do
          expect(JSON.parse(@response)["success"]).to be == "false"
        end
        it "The user should have 1 avatar left" do

        end
        it "the user's avatar should be default" do
          expect(JSON.parse(@user.user_avatars.count)).to be == 1
        end
      end

    end
    it "Should be able to remove the first avatar, and that automatically sets the last avatar to default" do

    end
    it "Should not be able to remove the last avatar" do

    end
  end

  describe "YJ Test" do

 @response = RestClient.post( "http://purpleoctopus-staging.herokuapp.com",
                          {
                            key: "2NihILTlrZ7idzwOzg3TRA",
                            beacon_key: "YJ-01-Vancouver-005AFT",
                            temperature: ((10...40).to_a).sample
                          }
                        )
  end

  describe "Server gets a notification of a client enters a beacon (/api/room/enter)" do

    before do
      @user = User.last
      @room = Room.last
      @beacon = @room.beacons.last
      @venue = @room.venue

      #emulate sending request from phone of entering a beacon
      @response = RestClient.post( "#{API_TEST_BASE_URL}/api/v1/room/enter",
                          {
                            key: @user.key,
                            beacon_key: @beacon.key,
                            temperature: ((10...40).to_a).sample
                          }
                        )

    end
    it "Should create a new participant for the room with the correct room/user id" do
      expect(@room.id).to be == Participant.last.room_id
      expect(@user.id).to be == Participant.last.user_id
    end
    it "Should return data of room id, and user to the phone ?"
    it "Should have a response code of 200" do
      expect(@response.code).to be == 200
    end

  end

  describe "Server gets a notification of a client exits a beacon (/api/room/leave)" do
    before do
      @user = User.last
      @room = Room.last
      @beacon = @room.beacons.last
      @venue = @room.venue
      RestClient.post( "#{API_TEST_BASE_URL}/api/v1/room/enter",
                          {
                            key: @user.key,
                            beacon_key: @beacon.key
                          }
                        )

      @response = RestClient.post( "#{API_TEST_BASE_URL}/api/v1/room/leave",
                          {
                            key: @user.key,
                            beacon_key: @beacon.key
                          }
                        )
    end
    it "Should have a response code of 200" do
      expect(@response.code).to be == 200
    end
    it "Should not be able to find a participant with the submitted room and user id" do
      expect(Participant.where(user_id: @user.id, room_id: @room.id).count).to be == 0
    end
  end

  describe "Server gets a request for the venue list (/api/venues/list)" do
    before do
      @user = User.last
      @response = RestClient.get( "#{API_TEST_BASE_URL}/api/v1/venues/list",
                            params:{
                              key: @user.key
                            }
                          )
    end
    it "returns all venues in the app" do
      expect(JSON.parse(@response)["data"].count).to be == Venue.all.count
    end
    it "Should have a response code of 200" do
      expect(@response.code).to be == 200
    end
    it "Should return venues in the current users's network only?"
    it "Should return venues between certain times?"
    it "Should return different attributes during the night?"
    it "Should return different attributes if the user is 'out'?"
  end

  describe "Client requests the user profile" do
    before do
      #create user
      #request profiles for current user token
    end
    it "Should return the profile (/api/profile)" do

    end
  end

  describe "Client sends the server new profile information (/api/users/update)" do
    before do
      #create user
      # create user profile
    end
    it "Should change the user information in the server" do

    end
    it "Should return success" do

    end
    it "Should update the user profile" do

    end
  end

  # describe "Lottery" do
  #   before do
  #     # create venue accounts
  #     # create 3 venues
  #     # create 10 users per venues
  #     # enter them via beaon call, and convert them into participants
  #   end
  #   describe "Venue logs in and clicks on lottery" do
  #     # enter login credentials
  #     it "should see a list of 10 participants in the venue" do

  #     end

  #     describe "Venue clicks selects a prize and draws a winner" do
  #       before do
  #         # click on lottery button
  #         # set the prize
  #       end
  #       it "should select a winner" do

  #       end
  #       it "should send the user a push notification and recieve that the push was pushed" do

  #       end
  #       it "should show the client the prize" do

  #       end
  #     end
  #   end
  # end 

  # describe "client adds a venue to his favorites" do

  # end

  # describe "client removes a venue from his favorites" do

  # end

  # describe "user views a list of his favorite venues" do

  # end

  # describe "clients sees a list of his favorite venues" do

  # end

end

  # TODO
# /apn/[user_id, data, resource, apn_key]
# /api/lottery/show

# what is claim?

# why do you need to update the apn??
# /api/users/update-apn

# /api/users/add_favorite_venue
# /api/users/remove_favorite_venue


# /api/venues/people --- current venue people

# /api/apn/from_user_token, to_user_token, apn_token, 

# /
# network/disconnect [user_token, network_id] 


# api/history/[resource, data]^
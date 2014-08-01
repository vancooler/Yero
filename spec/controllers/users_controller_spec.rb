require 'spec_helper'

describe UsersController do
  describe 'User Registration' do
    describe 'via a JSON request' do
      before do
        @new_user_json = {
          user:{
            email:                 "#{rand(36**8).to_s(36)}@example.com", 
            first_name:            "Jessica",
            birthday:              "#{Date.today - 20.years}",
            gender:                "F"
          }
        }
        @user_count = User.count
        post :sign_up, @new_user_json, {
          'Accept' => Mime::JSON,
          'Content-Type' => Mime::JSON.to_s
        }
      end

      it "should create a user" do
         expect(User.count).to be == @user_count + 1
      end
    end
  end
end

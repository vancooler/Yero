require 'spec_helper'

describe WhisperNotification do


	let(:user) { create(:user) }
	describe "test user" do
		context "friends" do
			it "same_venue_as?" do
		      	user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: (Time.now - 21.years), gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1")
		      	ua = UserAvatar.create!(user: user_2, default: true, order: 0)
		      	friend = FriendByWhisper.create!(target_user_id: 1, origin_user_id: 2, friend_time: Time.now, viewed: false)

		      	expect(WhisperNotification.myfriends(user).count).to eql 1
		      	expect(WhisperNotification.unviewd_whisper_number(user_2.id)[:friend_number]).to eql 1

		      	friend.destroy
		      	ua.destroy
		      	user_2.destroy

		      	expect(WhisperNotification.table_prefix).to eql ''
	      	end	
		end
	end


end
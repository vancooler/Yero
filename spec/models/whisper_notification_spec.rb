require 'spec_helper'

describe WhisperNotification do


	let(:user) { create(:user) }
	describe "test user" do
		context "friends" do
			it "same_venue_as?" do
		      	user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: (Time.now - 21.years), gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1")
		      	user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "123456", birthday: (Time.now - 21.years), gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1")
		      	ua = UserAvatar.create!(user: user_2, default: true, order: 0)
		      	friend = FriendByWhisper.create!(target_user_id: 1, origin_user_id: 2, friend_time: Time.now, viewed: false)

		      	expect(WhisperNotification.myfriends(user).count).to eql 1
		      	expect(WhisperNotification.unviewd_whisper_number(user_2.id)[:friend_number]).to eql 1

		      	expect(WhisperNotification.send_whisper('2', user_3, 0, '1', 'hello', "Something")).to eql "Please upload a profile photo first"
		      	expect(WhisperToday.count).to eql 0
		      	expect(WhisperSent.count).to eql 0
		      	expect(RecentActivity.count).to eql 0

		      	WhisperToday.create!(target_user_id: 3, origin_user_id: 2, whisper_type: '2', paper_owner_id: 3)
		      	expect(WhisperNotification.send_whisper('3', user_2, 0, '1', 'hello', "Something")).to eql "Cannot send more whispers"
		      	expect(WhisperToday.count).to eql 1
		      	expect(WhisperSent.count).to eql 0
		      	expect(RecentActivity.count).to eql 0
		      	WhisperToday.destroy_all
		      	
		      	BlockUser.create!(target_user_id: 2, origin_user_id: 3)
		      	expect(WhisperNotification.send_whisper('3', user_2, 0, '1', 'hello', "Something")).to eql "User blocked"
		      	expect(WhisperToday.count).to eql 0
		      	expect(WhisperSent.count).to eql 0
		      	expect(RecentActivity.count).to eql 0


		      	WhisperSent.destroy_all
		      	RecentActivity.destroy_all
		      	BlockUser.destroy_all
		      	friend.destroy
		      	ua.destroy
		      	user_2.destroy
		      	user_3.destroy

		      	expect(WhisperNotification.table_prefix).to eql ''
	      	end	
		end
	end


end
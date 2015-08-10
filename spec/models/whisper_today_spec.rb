require 'spec_helper'

describe WhisperToday do


	let(:user) { create(:user) }
	describe "test user" do
		context "whisper" do
			it "whispers test" do
				user_2 = User.create!(id:2, last_active: Time.now, first_name: "SF", email: "test2@yero.co", password: "123456", birthday: (Time.now - 21.years), gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", timezone_name: "America/Vancouver")
				user_3 = User.create!(id:3, last_active: Time.now, first_name: "SF", email: "test3@yero.co", password: "123456", birthday: (Time.now - 23.years), gender: 'F', latitude: 49.3857234, longitude: -123.0746173, is_connected: true, key:"1", timezone_name: "America/Vancouver")
		      	ua = UserAvatar.create!(user: user_2, default: true, order: 0)
		      	ua_1 = UserAvatar.create!(user: user_3, default: true, order: 0)
		      	whisper = WhisperToday.create!(target_user_id: 2, origin_user_id: 3, created_at: Time.now, viewed: false, whisper_type: "2")

		      	expect(WhisperToday.unviewed_whispers_count(2)).to eql 1
		      	expect(WhisperToday.to_json([whisper]).count).to eql 1
		      	expect(WhisperNotification.unviewd_whisper_number(user_2.id)[:whisper_number]).to eql 1

		      	whisper.destroy
		      	ua.destroy
		      	ua_1.destroy
		      	user_2.destroy
		      	user_3.destroy

			end
		end
	end
end

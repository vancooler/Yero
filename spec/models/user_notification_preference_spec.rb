require 'spec_helper'

describe UserNotificationPreference do


	let(:user) { create(:user) }
	describe "test UserNotificationPreference" do
		context "check no preference" do
			it "no_preference_record_found" do
				expect(UserNotificationPreference.no_preference_record_found(user, "something")).to eql true
				np = NotificationPreference.create!(name: "something")
				unp = UserNotificationPreference.create!(user_id: 1, notification_preference_id: np.id)
				expect(UserNotificationPreference.no_preference_record_found(user, "something")).to eql false
				unp.destroy
				np.destroy
			end


			it "update_preferences_settings" do

				NotificationPreference.create!(name: "Network online")
				NotificationPreference.create!(name: "Enter venue network")
				NotificationPreference.create!(name: "Leave venue network")
				UserNotificationPreference.update_preferences_settings(user, true, true, true)
				expect(user.user_notification_preference.count).to eql 3
				UserNotificationPreference.update_preferences_settings(user, false, false, false)
				expect(user.user_notification_preference.count).to eql 0
				NotificationPreference.destroy_all

			end
		end
	end
end
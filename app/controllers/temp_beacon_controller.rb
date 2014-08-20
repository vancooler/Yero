class TempBeaconController < ApplicationController
  def enter_random_users
    output = "Entering random users into venues...<br/>"

    beacons = %w[Vancouver_Aubar_room01_039MNB Vancouver_Republic_barupstairs_01_005AFT]
    20.times do 
      user = User.all.sample
      beacon = Beacon.find_by(key:beacons.sample)
      activity = Activity.create(user: user, trackable: beacon, action: "Enter Beacon")
      output += "User: #{user.key}                 Entered Beacon: #{beacon.key}          on #{activity.created_at}"
      output += "</br>"
    end
    render text: output, :layout => false
  end
  def exit_active_users
    output = ""
    beacons = %w[Vancouver_Aubar_room01_039MNB Vancouver_Republic_barupstairs_01_005AFT]
    User.all.each do |user|
      if user.has_activity_today? && user.last_activity.action == "Enter Beacon"
        beacon = Beacon.find_by(key:beacons.sample)
        activity = Activity.create(user: user, trackable: beacon, action: "Exit Beacon")
        output += "User: #{user.key}                 Exited Beacon: #{beacon.key}          on #{activity.created_at}"
        output += "</br>"
      end
    end
    output = "All users have already left." if output.blank?
    render text: output, :layout => false
  end
end
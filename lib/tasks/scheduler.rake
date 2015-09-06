task :venue_locs => :environment do
  puts "Converting current venues address..."

  venues = Venue.all

  venues.each do |v|

    address = "#{v.address_line_one}, #{v.city}, #{v.state}"
    puts "Finding location for #{address}..."
    loc = Geocoder.coordinates(address)

    if loc
      puts "Location found, saving to database..."
      v.latitude = loc[0]
      v.longitude = loc[1]
      v.save
    else
      puts "Location not found, skipping"
    end
  end

  puts "Done"
end


task :network_close => :environment do
  puts "Checking for networks approaching 5am"
  User.network_close
  puts "Done."
end

task :fake_users_join => :environment do
  puts "Random join fake users at 5pm"
  User.fake_users_join
  puts "Done."
end

task :whisper_expire => :environment do
  puts "Expire whispers without replies older than 12 hours"
  WhisperToday.expire
  puts "Done."
end



task :sync_gimbal => :environment do
  puts "Start to sync gimbal places"
  CityNetwork.sync_gimbal
  puts "Done."
end


task :enough_users => :environment do
  puts "Checking for enough users"

  

  # Send a notification to previous joint users -> enough users now
  gate_number = 4
  # if set in db, use the db value
  if GlobalVariable.exists? name: "min_ppl_size"
    size = GlobalVariable.find_by_name("min_ppl_size")
    if !size.nil? and !size.value.nil? and size.value.to_i > 0
      gate_number = size.value.to_i
    end
  end

  User.where(:is_connected => true).where(:fake_user => false).where(:enough_user_notification_sent_tonight => false).find_each do |joint_user|
    all_users = joint_user.fellow_participants(false, nil, 0, 100, nil, 0, 60, true)
    number_of_users = all_users.length + 1
    if number_of_users >= gate_number  
      WhisperNotification.send_enough_users_notification(joint_user.id)
      joint_user.enough_user_notification_sent_tonight = true
      joint_user.save!
    end
  end


  puts "Done."
end


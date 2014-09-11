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

#cleanup for user activity in venue and venue network
namespace :cleanup do
include ActionView::Helpers::DateHelper
  task :everyday_venue_cleanup => :environment do 
    ActiveInVenue.clean_up
  end

  task :network_cleanup => :environment do 
    ActiveInVenueNetwork.everyday_cleanup
  end



  task :random_test => :environment do 
    scale = 200
    i = 1
    file = File.open("test_result.txt", "w")
    venues = Venue.all
    users = User.all
    users_count = users.count
    venues_count = venues.count
    while i <= scale do
      file.write("Test " + i.to_s + ": \n")
      venue_id = rand(venues.count)
      user_id = rand(users_count)
      venue = venues[venue_id]
      user = users[user_id]

      pArray = ActiveInVenue.where("venue_id = ? and user_id = ?", venue.id, user.id)
      if pArray and pArray.count > 0
        ActiveInVenue.leave_venue(venue, user)
        file.write("    User " + user.id.to_s + " left venue " + venue.id.to_s + " \n")
      else
        ActiveInVenue.enter_venue(venue, user)
        file.write("    User " + user.id.to_s + " entered venue " + venue.id.to_s + " \n")
      end

      file.write("        Current ActiveInVenue: \n")
      aivs = ActiveInVenue.all
      file.write("        | VenueID | UserID | LastActivity |\n")
      aivs.each do |aiv|
        file.write("        |   " + aiv.venue_id.to_s + "    |   " + aiv.user_id.to_s + "    | " + distance_of_time_in_words_to_now(aiv.last_activity) + " |\n")
      end
      file.write("        Current ActiveInVenueNetwork: \n")
      aivns = ActiveInVenueNetwork.all
      file.write("        | VenueNWID | UserID | LastActivity |\n")
      aivns.each do |aivn|
        file.write("        |     " + aivn.venue_network_id.to_s + "     |   " + aivn.user_id.to_s + "    | " + distance_of_time_in_words_to_now(aivn.last_activity) + " |\n")
      end
      file.write("\n\n")
      if i == scale / 2
        ActiveInVenue.clean_up
        ActiveInVenueNetwork.everyday_cleanup

        file.write("\n*******************************************************************\n*\n* It is 8 AM now!\n")
        file.write("*       Current ActiveInVenue: \n")
        aivs = ActiveInVenue.all
        file.write("*       | VenueID | UserID | LastActivity |\n")
        aivs.each do |aiv|
          file.write("*       |   " + aiv.venue_id.to_s + "    |   " + aiv.user_id.to_s + "    | " + distance_of_time_in_words_to_now(aiv.last_activity) + " |\n")
        end
        file.write("*       Current ActiveInVenueNetwork: \n")
        aivns = ActiveInVenueNetwork.all
        file.write("*       | VenueNWID | UserID | LastActivity |\n")
        aivns.each do |aivn|
          file.write("*       |     " + aivn.venue_network_id.to_s + "     |   " + aivn.user_id.to_s + "    | " + distance_of_time_in_words_to_now(aivn.last_activity) + " |\n")
        end
        file.write("*\n*******************************************************************\n\n")
      end
      i += 1
    end

  end
end
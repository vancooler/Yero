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
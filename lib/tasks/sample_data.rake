namespace :db do
  desc'Fill database with sample data'

  task populate_settings: :environment do
    # admin set variables go here, such as cut-off time of the night, etc,..
  end

  task seed: :environment do
    # rough sample data
    user = User.create!(
        birthday: Time.now - 28.years,
        first_name: 'Alex',
        gender:'Male',
        key: loop do
          random_token = SecureRandom.urlsafe_base64(nil, false)
          break random_token unless User.exists?(key: random_token)
        end
      )
    user2 = User.create!(
        birthday: Time.now - 28.years,
        first_name: 'Lyosha',
        gender:'Male',
        key: loop do
          random_token = SecureRandom.urlsafe_base64(nil, false)
          break random_token unless User.exists?(key: random_token)
        end
    )

    Poke.create(pokee: user2, poker: user)
    Poke.create(pokee: user, poker: user2)
    

    network = VenueNetwork.create(
        city: "Vancouver",
        area: 2,
        name: "Vancouver Night Life"
      )
    10.times do |n|
      [user,user2].sample.venues.create!(
          name:"Venue #{n}",
          password: 'subway11',
          password_confirmation: 'subway11',
          email: 'lyosha85+yero_sample_venue@gmail.com',
          venue_network_id: VenueNetwork.first.id,
          age_requirement: '19+',
          dress_code: ['Formal','Casual','Semi-Formal','No Dress Code'].sample,
          address_line_one: "Unit #{[55,66,77,88,99].sample}",
          address_line_two: "#{[12,32,44,22,77,86,123].sample} Granville Street"


        )
    end

    beacons = [
        {name: "Bar - Downstairs", key: "1"},
        {name: "Dance Area - Downstairs", key: "2"},
        {name: "Bar - Upstairs", key: "3"},
        {name: "VIP Lounge - Upstairs", key: "4"},
        {name: "Dance Room - Upstairs", key: "5"},
        {name: "ATM/Washroom Enterance - Upstairs", key: "6"},
        {name: "Line Area", key: "7"},
        {name: "Smoking Area", key: "8"},
      ]
    venue = Venue.last
    4.times do 
      room = venue.rooms.create!
      2.times {room.beacons << Beacon.new(beacons.pop)}
    end

    p "Seed complete."

  end
end

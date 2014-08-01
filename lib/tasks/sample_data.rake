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
        gender:'Male'
      )
    user2 = User.create!(
        birthday: Time.now - 28.years,
        first_name: 'Lyosha',
        gender:'Male'
    )

    Poke.create(pokee: user2, poker: user)
    Poke.create(pokee: user, poker: user2)
    

    user.venues.create!(
        name:'Republic',
        password: 'subway11',
        password_confirmation: 'subway11',
        email: 'lyosha85+yero_sample_venue@gmail.com'
      )
    network = VenueNetwork.create(
        city: "Vancouver",
        area: 2,
        name: "Vancouver Night Life"
      )
    venue = user.venues.first
    network.venues << venue

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

    4.times do 
      room = venue.rooms.create!
      2.times {room.beacons << Beacon.new(beacons.pop)}
    end

    p "Seed complete."

  end
end

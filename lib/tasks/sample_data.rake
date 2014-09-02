namespace :db do
  desc'Fill database with sample data'

  task populate_settings: :environment do
    # admin set variables go here, such as cut-off time of the night, etc,..
  end

  task seed: :environment do
    # rough sample data
    User.create!(
        birthday: Time.now - 28.years,
        first_name: 'Alex',
        gender:'Male',
        key: loop do
          random_token = SecureRandom.urlsafe_base64(nil, false)
          break random_token unless User.exists?(key: random_token)
        end
      )
    User.create!(
        birthday: Time.now - 28.years,
        first_name: 'Lyosha',
        gender:'Male',
        key: loop do
          random_token = SecureRandom.urlsafe_base64(nil, false)
          break random_token unless User.exists?(key: random_token)
        end
    )

    network = VenueNetwork.create(
        city: "Vancouver",
        area: 2,
        name: "Vancouver Night Life"
      )
    web_user = WebUser.create!(
      first_name: "Bobby",
      last_name: "T",
      email: "hello+#{("abcd".."wxyz").to_a.sample}@yero.co",
      password: "foobar11",
      password_confirmation:"foobar11",
      business_name:"Bobby's Night Clubs",
      address_line_1: "123 Granville Street",
      city: "Vancouver",
      state: "BC",
      country:"Canada",
      zipcode:"V7S1A1",
      business_phone:"6046000000"
    )

    VenueType.create!(name:"Test")

    10.times do |n|
      web_user.venues.create!(
          name:"Venue #{n}",
          email: "lyosha85+#{n}_#{("abcd".."wxyz").to_a.sample
}@gmail.com",
          city: "Vancouver",
          country: "Canada",
          state: "BC",
          zipcode:"v7s1a1",
          venue_type_id: VenueType.all.sample.id,
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

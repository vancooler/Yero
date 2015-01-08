FactoryGirl.define do  factory :prospect_city_client do
    
  end

  factory :user do
    sequence(:first_name)  { |n| "Person-#{n}" }
    birthday Time.now - ((19...100).to_a).sample.years
    gender ['M','F'].sample
    key {
      loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless User.exists?(key: random_token)
      end
    }
    factory :user_with_avatar do
      after(:create) do |user|
        UserAvatar.create(user: user, default: true)
      end
    end
  end

  factory :venue do
    sequence(:name)  { |n| "Venue #{n}" }
    sequence(:email) { |n| "venue_#{n}@example.com" }
    city 'Vancouver'
    state 'BC'
    country 'Canada'
    zipcode 'V7S1B2'
    dress_code 'Formal'
    phone '6041234567'
    address_line_one '123 Granville Street'
    # association :venue_network, factory: :venue_network
    venue_network
    venue_type
  end

  factory :venue_type do
    sequence(:name) { |n| "type-#{n}" }
  end

  factory :room do
    sequence(:name) {|n| "Room #{n}"}
    venue
  end

  factory :beacon do
    sequence(:key) {"Vancouver_Aubar_Dance_#{n}_123123"}
  end

  factory :user_avatar do
    user
    avatar Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/files/sample_avatar.jpg')))
  end

  factory :venue_network do
    sequence(:area) {|n| n}
    sequence(:name) {|n| "Sample Name #{n}"}
    city 'Vancouver'
  end

  factory :web_user do
    first_name      Faker::Name.first_name
    last_name       Faker::Name.last_name
    business_name   Faker::Company.name
    address_line_1  Faker::Address.street_address
    address_line_2  Faker::Address.secondary_address
    city            "Vancouver"
    state           "BC"
    country         "Canada"
    zipcode         "v7s1a1"
    business_phone  Faker::PhoneNumber.phone_number
    cell_phone      Faker::PhoneNumber.phone_number
    email           Faker::Internet.email
    password        "foobar11"
    password_confirmation "foobar11"
  end
end
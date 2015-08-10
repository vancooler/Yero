FactoryGirl.define do  factory :global_variable do
    name "MyString"
value "MyString"
  end
  factory :time_zone do
    
  end
  factory :prospect_city_client do
    
  end

  factory :user do
    sequence(:first_name)  { |n| "Person-#{n}" }
    birthday Time.now - 20.years
    gender ['M','F'].sample
    email "test@yero.co"
    password "123456"
    latitude 49.3457234
    longitude -123.0846173
    id 1
    key {
      loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless User.exists?(key: random_token)
      end
    }
    factory :user_with_avatar do
      after(:create) do |user|
        UserAvatar.create(user: user, default: true, order: 0)
      end
    end
  end

  factory :user_2 do
    sequence(:first_name)  { |n| "Person-#{n}" }
    birthday Time.now - 21.years
    gender ['M','F'].sample
    email "test+2@yero.co"
    password "123456"
    latitude 49.3457234
    longitude -123.0846173
    id 2
    key {
      loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless User.exists?(key: random_token)
      end
    }
    factory :user_with_avatar_2 do
      after(:create) do |user|
        UserAvatar.create(user: user, default: true, order: 0)
      end
    end
  end

  factory :active_in_venue do
    user_id 1
    venue_id 1
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
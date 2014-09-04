FactoryGirl.define do
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
    sequence(:name) { "type-#{n}" }
  end

  factory :room do
    sequence(:name) {|n| "Room #{n}"}
    venue
  end

  factory :beacon do
    sequence(:name) {"Vancouver_Aubar_Dance_#{n}_123123"}
  end

  factory :user_avatar do
    user
  end

  factory :venue_network do
    sequence(:area) {|n| n}
    sequence(:name) {|n| "Sample Name #{n}"}
    city 'Vancouver'
  end
end
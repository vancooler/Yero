FactoryGirl.define do
  factory :user do
    sequence(:first_name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    birthday Time.now - ((19...100).to_a).sample.years
    gender ['M','F'].sample
  end
  
  factory :venue do
    sequence(:name)  { |n| "Venue #{n}" }
    sequence(:email) { |n| "venue_#{n}@example.com" }
    password 'LabasVakaras'
    password_confirmation 'LabasVakaras'
    city 'Vancouver'
    state 'BC'
    country 'Canada'
    zipcode 'V7S1B2'
    dress_code 'Formal'
    phone '6041234567'
  end
  factory :venue_network do
    sequence(:area) {|n| n}
    city 'Vancouver'
    name 'Downtown Vancouver'
  end
end
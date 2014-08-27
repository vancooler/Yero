FactoryGirl.define do
  factory :user do
    sequence(:first_name)  { |n| "Person #{n}" }
    # sequence(:email) { |n| "person_#{n}@example.com"}
    birthday Time.now - ((19...100).to_a).sample.years
    gender ['M','F'].sample
    key {
      loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless User.exists?(key: random_token)
      end
    }
    factory :user_with_avatars do
      after_create do |user|
        create(:user_avatar, user: user)
        create(:user_avatar, user: user)
        create(:user_avatar, user: user)
      end
    end
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
    association :venue_network, factory: :venue_network
  end
  factory :room do

  end

  factory :user_avatar do

  end

  factory :venue_network do
    sequence(:area) {|n| n}
    city 'Vancouver'
    sequence(:name) {|n| "Sample Name #{n}"}
  end
end
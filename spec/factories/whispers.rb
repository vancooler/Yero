# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :whisper do
    origin_id 1
    target_id 1
    viewed false
    accepted false
  end
end

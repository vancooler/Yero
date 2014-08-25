# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :read_notification, :class => 'ReadNotifications' do
    user nil
    before_sending_whisper_notification false
  end
end

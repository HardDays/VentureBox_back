FactoryBot.define do
  factory :user do
    name { Faker::Lorem.word }
    surname { Faker::Lorem.word }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    goals { Faker::Lorem.paragraph }
    is_email_notifications_available { Faker::Boolean.boolean }
    phone { Faker::PhoneNumber.phone_number }
    role { Faker::Number.between(0, 1) }
  end
end

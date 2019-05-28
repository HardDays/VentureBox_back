FactoryBot.define do
  factory :milestone do
    title { Faker::Lorem.word }
    description { Faker::Lorem.paragraph }
    finish_date { Faker::Date.forward }
  end
end

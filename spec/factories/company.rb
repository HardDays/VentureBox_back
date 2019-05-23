FactoryBot.define do
  factory :company do
    name { Faker::Lorem.word }
    website { Faker::Internet.domain_name }
    description { Faker::Lorem.paragraph }
  end
end

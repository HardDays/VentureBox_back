FactoryBot.define do
  factory :company_item do
    name { Faker::Lorem.word }
    link_to_store { Faker::Internet.url }
    price { Faker::Number.between(10, 1000) }
    description { Faker::Lorem.paragraph }
  end
end

FactoryBot.define do
  factory :company_item do
    name { Faker::Lorem.word }
    product_type { Faker::Lorem.word }
    price { Faker::Number.between(10, 1000) }
    description { Faker::Lorem.paragraph }
  end
end

FactoryBot.define do
  factory :company_item do
    name { Faker::Lorem.word }
    link_to_store { Faker::Internet.domain_name }
    status { Faker::Number.between(0, 2) }
    price { Faker::Number.between(10, 1000) }
    description { Faker::Lorem.paragraph }
  end
end

FactoryBot.define do
  factory :company do
    company_name { Faker::Lorem.word }
    website { Faker::Internet.domain_name }
    description { Faker::Lorem.paragraph }
    contact_email { Faker::Internet.email }
    stage_of_funding { Faker::Number.between(0, 5) }
    investment_amount { Faker::Number.between(1000, 1000000) }
    equality_amount { Faker::Number.between(1, 99) }
  end
end

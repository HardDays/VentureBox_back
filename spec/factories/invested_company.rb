FactoryBot.define do
  factory :invested_company do
    investment { Faker::Number.between(50000, 5000000) }
    evaluation { Faker::Number.between(1, 100) }
    contact_email { Faker::Internet.email }
  end
end

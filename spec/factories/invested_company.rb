FactoryBot.define do
  factory :invested_company do
    investment { Faker::Number.between(50000, 5000000) }
    evaluation { Faker::Number.between(1, 100) }
    contact_email { Faker::Internet.email }
    date_from { DateTime.now }
    date_to { DateTime.now.next_year(1) }
  end
end

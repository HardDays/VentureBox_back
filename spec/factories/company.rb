FactoryBot.define do
  factory :company do
    name { Faker::Lorem.word }
    website { Faker::Internet.domain_name }
    description { Faker::Lorem.paragraph }
    contact_email { Faker::Internet.email }
  end
end

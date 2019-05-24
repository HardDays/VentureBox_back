FactoryBot.define do
  factory :startup_news do
    text { Faker::Lorem.paragraph }
  end
end


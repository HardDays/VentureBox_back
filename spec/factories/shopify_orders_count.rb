FactoryBot.define do
  factory :shopify_orders_count do
    count { Faker::Number.between(1, 10) }
    date { DateTime.now }
  end
end

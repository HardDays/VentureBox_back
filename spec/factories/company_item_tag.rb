FactoryBot.define do
  factory :company_item_tag do
    tag { Faker::Number.between(0, 4) }
  end
end

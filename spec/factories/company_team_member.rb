FactoryBot.define do
  factory :company_team_member do
    team_member_name { Faker::Lorem.word }
    c_level { Faker::Number.between(0, 8) }
  end
end

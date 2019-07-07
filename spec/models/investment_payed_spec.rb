require 'rails_helper'

RSpec.describe InvestmentPayed, type: :model do
  it { should validate_presence_of(:amount) }
  it { should validate_presence_of(:invested_company_id) }
  it { should validate_presence_of(:date) }

  it { should belong_to(:invested_company) }
end

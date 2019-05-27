require 'rails_helper'

RSpec.describe InterestingCompany, type: :model do
  it { should validate_presence_of(:investor_id) }
  it { should validate_presence_of(:company_id) }
  it { should validate_uniqueness_of(:company_id).scoped_to(:investor_id) }

  it { should belong_to(:user) }
  it { should belong_to(:company) }
end

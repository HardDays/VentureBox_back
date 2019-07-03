require 'rails_helper'

RSpec.describe InvestedCompany, type: :model do
  it { should validate_presence_of(:investor_id) }
  it { should validate_presence_of(:company_id) }
  it { should validate_presence_of(:contact_email) }
  it { should validate_presence_of(:investment) }
  it { should validate_presence_of(:evaluation) }
  it { should validate_presence_of(:date_from) }
  it { should validate_presence_of(:date_to) }

  it { should belong_to(:user) }
  it { should belong_to(:company) }
end

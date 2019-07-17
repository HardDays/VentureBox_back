require 'rails_helper'

RSpec.describe ShopifyOrdersSumm, type: :model do
  it { should validate_presence_of(:company_id) }
  it { should validate_presence_of(:price) }
  it { should validate_presence_of(:date) }

  it { should belong_to(:company) }
end

require 'rails_helper'

RSpec.describe ShopifyOrdersCount, type: :model do
  it { should validate_presence_of(:company_item_id) }
  it { should validate_presence_of(:count) }
  it { should validate_presence_of(:date) }

  it { should belong_to(:company_item) }
end

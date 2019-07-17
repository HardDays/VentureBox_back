require 'rails_helper'

RSpec.describe CompanyItem, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:product_type) }
  it { should validate_presence_of(:price) }
  it { should validate_presence_of(:company_id) }

  it { should belong_to(:company) }
  it { should belong_to(:country) }
  it { should have_one(:company_item_image).dependent(:destroy) }
  it { should have_many(:company_item_tags).dependent(:destroy) }
  it { should have_many(:shopify_orders_counts).dependent(:destroy) }
end

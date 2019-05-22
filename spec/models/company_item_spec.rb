require 'rails_helper'

RSpec.describe CompanyItem, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:link_to_store) }
  it { should validate_presence_of(:company_id) }

  it { should belong_to(:company) }
  it { should have_many(:company_item_tags).dependent(:destroy) }
end

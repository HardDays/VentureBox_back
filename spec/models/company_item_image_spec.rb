require 'rails_helper'

RSpec.describe CompanyItemImage, type: :model do
  it { should validate_presence_of(:base64) }
  it { should validate_presence_of(:company_item_id) }

  it { should belong_to(:company_item) }
  it { should have_many(:resized_company_item_images).dependent(:destroy) }
end

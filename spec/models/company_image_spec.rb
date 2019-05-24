require 'rails_helper'

RSpec.describe CompanyImage, type: :model do
  it { should validate_presence_of(:base64) }
  it { should validate_presence_of(:company_id) }

  it { should belong_to(:company) }
  it { should have_many(:resized_company_images).dependent(:destroy) }
end

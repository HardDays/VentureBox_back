require 'rails_helper'

RSpec.describe ResizedCompanyImage, type: :model do
  it { should validate_presence_of(:base64) }
  it { should validate_presence_of(:width) }
  it { should validate_presence_of(:height) }
  it { should validate_presence_of(:company_image_id) }

  it { should belong_to(:company_image) }
end

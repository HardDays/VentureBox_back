require 'rails_helper'

RSpec.describe CompanyItemTag, type: :model do
  it { should validate_presence_of(:tag) }

  it { should belong_to(:company_item) }
end

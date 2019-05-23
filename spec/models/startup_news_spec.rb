require 'rails_helper'

RSpec.describe StartupNews, type: :model do
  it { should validate_presence_of(:text) }
  it { should validate_presence_of(:company_id) }

  it { should belong_to(:company) }
end

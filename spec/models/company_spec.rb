require 'rails_helper'

RSpec.describe Company, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:website) }

  it { should belong_to(:user) }
  it { should have_many(:company_items).dependent(:destroy) }
  it { should have_many(:startup_news).dependent(:destroy) }
end

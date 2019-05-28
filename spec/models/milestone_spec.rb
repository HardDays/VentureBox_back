require 'rails_helper'

RSpec.describe Milestone, type: :model do
  it { should validate_presence_of(:company_id) }
  it { should validate_presence_of(:finish_date) }
  it { should validate_presence_of(:title) }

  it { should belong_to(:company) }
end

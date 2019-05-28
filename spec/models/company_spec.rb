require 'rails_helper'

RSpec.describe Company, type: :model do
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:company_name) }
  it { should validate_presence_of(:contact_email) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:stage_of_funding) }

  it { should belong_to(:user) }
  it { should have_one(:company_image).dependent(:destroy) }
  it { should have_many(:company_items).dependent(:destroy) }
  it { should have_many(:startup_news).dependent(:destroy) }
  it { should have_many(:invested_companies).dependent(:destroy) }
  it { should have_many(:interesting_companies).dependent(:destroy) }
  it { should have_many(:company_team_members).dependent(:destroy) }
end

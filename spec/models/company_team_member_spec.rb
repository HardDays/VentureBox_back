require 'rails_helper'

RSpec.describe CompanyTeamMember, type: :model do
  it { should validate_presence_of(:company_id) }
  it { should validate_presence_of(:team_member_name) }
  it { should validate_presence_of(:c_level) }

  it { should belong_to(:company) }
end

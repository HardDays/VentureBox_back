class CompanyTeamMember < ApplicationRecord
  validates_presence_of :company_id, :team_member_name, :c_level

  enum c_level: EnumsHelper.c_level

  belongs_to :company
end

class CompanyTeamMember < ApplicationRecord
  validates_presence_of :company_id, :team_member_name, :c_level

  enum c_level: [:cto, :cfo, :cio, :coo, :cco, :cko, :cso, :cdo, :cmo]

  belongs_to :company
end

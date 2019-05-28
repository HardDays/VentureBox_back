class InterestingCompany < ApplicationRecord
  validates_presence_of :investor_id, :company_id
  validates_uniqueness_of :company_id, scope: :investor_id

  belongs_to :user, foreign_key: :investor_id
  belongs_to :company

  def as_json(options={})
    res = super(options)

    res[:company_name] = company.company_name

    res
  end
end

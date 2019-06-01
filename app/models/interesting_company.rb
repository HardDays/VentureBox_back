class InterestingCompany < ApplicationRecord
  validates_presence_of :investor_id, :company_id
  validates_uniqueness_of :company_id, scope: :investor_id

  belongs_to :user, foreign_key: :investor_id
  belongs_to :company

  def as_json(options={})
    res = super(options)

    res[:company_name] = company.company_name

    if options[:list]
      res[:evaluation] = 0
      if company.invested_companies.exists?
        investment = company.invested_companies.last
        res[:evaluation] = (investment.investment / (investment.evaluation * 0.01)).ceil
      elsif company.investment_amount and company.equality_amount
        res[:evaluation] = (company.investment_amount / (company.equality_amount * 0.01)).ceil
      end
    end

    res
  end
end

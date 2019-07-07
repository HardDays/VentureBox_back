class InvestmentPayed < ApplicationRecord
  validates_presence_of :amount, :invested_company_id, :date
  validates_uniqueness_of :invested_company_id, scope: :date

  belongs_to :invested_company

  before_save :convert_date

  def convert_date
    if self.date
      self.date = self.date.utc.beginning_of_month
    end
  end
end

class ShopifyOrdersSumm < ApplicationRecord
  validates_presence_of :company_id, :price, :date

  belongs_to :company

  before_save :convert_date

  def convert_date
    self.date = self.date.beginning_of_day
  end
end

class ShopifyOrdersCount < ApplicationRecord
  validates_presence_of :company_item_id, :count, :date
  validates_uniqueness_of :company_item_id, scope: :date

  belongs_to :company_item

  before_save :convert_date

  def convert_date
    self.date = self.date.beginning_of_day
  end
end

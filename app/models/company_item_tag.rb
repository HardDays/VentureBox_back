class CompanyItemTag < ApplicationRecord
  validates_presence_of :tag

  enum tag: [:blockchain, :coding, :real_sector, :product, :fintech]

  belongs_to :company_item
end

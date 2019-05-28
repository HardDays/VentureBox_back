class CompanyItemTag < ApplicationRecord
  validates_presence_of :tag

  enum tag: EnumsHelper.company_item_tag

  belongs_to :company_item
end

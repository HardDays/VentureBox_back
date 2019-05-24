class CompanyItemImage < ApplicationRecord
  validates_presence_of :base64
  validates_presence_of :company_item_id
  validates_uniqueness_of :company_item_id

  belongs_to :company_item
  has_many :resized_company_item_images, dependent: :destroy
end

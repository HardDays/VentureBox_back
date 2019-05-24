class ResizedCompanyItemImage < ApplicationRecord
  validates_presence_of :base64
  validates_presence_of :width
  validates_presence_of :height
  validates_presence_of :company_item_image_id

  belongs_to :company_item_image
end

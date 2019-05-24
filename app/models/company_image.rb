class CompanyImage < ApplicationRecord
  validates_presence_of :base64
  validates_presence_of :company_id
  validates_uniqueness_of :company_id

  belongs_to :company
  has_many :resized_company_images, dependent: :destroy
end

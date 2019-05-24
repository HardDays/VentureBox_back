class CompanyItem < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :link_to_store, url: true
  validates_presence_of :company_id

  belongs_to :company
  has_many :company_item_tags, dependent: :destroy
end

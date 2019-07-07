class Country < ApplicationRecord
  validates_presence_of :name

  has_many :company_items
end

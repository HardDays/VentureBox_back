class Company < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :website

  belongs_to :user
  has_many :company_items, dependent: :destroy
  has_many :startup_news, dependent: :destroy
end

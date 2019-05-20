class Company < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :website

  belongs_to :user
end

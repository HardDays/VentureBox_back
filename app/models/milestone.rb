class Milestone < ApplicationRecord
  validates_presence_of :title, :company_id, :finish_date

  belongs_to :company
end

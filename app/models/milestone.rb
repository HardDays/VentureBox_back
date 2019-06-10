class Milestone < ApplicationRecord
  validates_presence_of :title, :company_id, :finish_date
  validates_inclusion_of :completeness, in: 0..100

  belongs_to :company
end

class StartupNews < ApplicationRecord
  validates_presence_of :text
  validates_presence_of :company_id

  belongs_to :company
end

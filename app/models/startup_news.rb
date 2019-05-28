class StartupNews < ApplicationRecord
  validates_presence_of :text
  validates_presence_of :company_id

  belongs_to :company

  def as_json(options={})
    res = super(options)

    res[:company_name] = company.company_name
    res
  end
end

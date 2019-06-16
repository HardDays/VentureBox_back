class InterestingCompany < ApplicationRecord
  validates_presence_of :investor_id, :company_id
  validates_uniqueness_of :company_id, scope: :investor_id

  belongs_to :user, foreign_key: :investor_id
  belongs_to :company

  def as_json(options={})
    res = super(options)
    if options[:only]
      return res
    end

    if options[:investor_companies]
      res.delete("investor_id")
      res.delete("created_at")
      res.delete("updated_at")
      res[:company_name] = company.company_name
      return res
    end

    if options[:list]
      res[:company_name] = company.company_name
      res[:company_has_image] = false
      if company.company_image
        res[:company_has_image] = true
      end

      res[:evaluation] = company.get_evaluation
    end

    res
  end
end

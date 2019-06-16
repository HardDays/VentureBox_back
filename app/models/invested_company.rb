class InvestedCompany < ApplicationRecord
  validates_presence_of :investor_id, :company_id, :contact_email, :investment, :evaluation
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, unless: Proc.new { |a| a.contact_email.blank? }

  belongs_to :user, foreign_key: :investor_id
  belongs_to :company

  default_scope { order(created_at: :desc) }

  def as_json(options={})
    res = super(options)
    if options[:only]
      return res
    end

    if options[:investor_companies]
      res.delete("investor_id")
      res.delete("created_at")
      res.delete("update_at")
      res.delete("contact_email")
      res.delete("investment")
      res.delete("evaluation")
      res[:company_name] = company.company_name
      return res
    end

    if options[:list]
      res.delete('contact_email')
    end

    if options[:investor]
      res[:investor_name] = "#{user.surname} #{user.name}"
      res[:investor_email] = user.email
    end

    if options[:list]
      res[:company_name] = company.company_name
      res[:company_has_image] = false
      if company.company_image
        res[:company_has_image] = true
      end
    end

    res
  end
end

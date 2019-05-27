class InvestedCompany < ApplicationRecord
  validates_presence_of :investor_id, :company_id, :contact_email, :investment, :evaluation
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }, unless: Proc.new { |a| a.contact_email.blank? }

  belongs_to :user, foreign_key: :investor_id
  belongs_to :company

  def as_json(options={})
    res = super(options)

    if options[:list]
      res.delete('contact_email')
    end

    if options[:investor]
      res[:investor_name] = "#{user.surname} #{user.name}"
      res[:investor_email] = contact_email
    end

    res[:company_name] = company.name

    res
  end
end

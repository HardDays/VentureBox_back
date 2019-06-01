class Company < ApplicationRecord
  validates_presence_of :user_id, :company_name, :stage_of_funding, :description
  validates :website, url: true, unless: Proc.new { |a| a.website.blank? }
  validates :contact_email, :presence => true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :equality_amount, :inclusion => 1..99, unless: Proc.new { |a| a.equality_amount.blank? }

  enum stage_of_funding: EnumsHelper.stage_of_funding

  belongs_to :user
  has_one :company_image, dependent: :destroy
  has_many :company_items, dependent: :destroy
  has_many :startup_news, dependent: :destroy
  has_many :invested_companies, dependent: :destroy
  has_many :interesting_companies, dependent: :destroy
  has_many :company_team_members, dependent: :destroy
  has_many :milestones, dependent: :destroy

  def as_json(options={})
    res = super(options)

    if options[:list]
      res.delete('website')
      res.delete('description')
      res.delete('contact_email')
      res.delete('created_at')
      res.delete('updated_at')
    else
      res[:team_members] = company_team_members.as_json(only: [:team_member_name, :c_level])
    end

    res.delete('image')
    res
  end
end

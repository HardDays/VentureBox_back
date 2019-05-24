class Company < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :website
  validates :website, url: true, unless: Proc.new { |a| a.website.blank? }
  validates :contact_email, :allow_blank => true, format: { with: URI::MailTo::EMAIL_REGEXP }

  belongs_to :user
  has_many :company_items, dependent: :destroy
  has_many :startup_news, dependent: :destroy

  def as_json(options={})
    res = super(options)

    res.delete('image')
    res
  end
end

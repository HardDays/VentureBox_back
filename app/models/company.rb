class Company < ApplicationRecord
  validates_presence_of :user_id, :company_name, :stage_of_funding, :description
  validates :website, url: true, unless: Proc.new { |a| a.website.blank? }
  validates :website, http_url: true, unless: Proc.new { |a| a.website.blank? }
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
    if options[:only]
      return res
    end

    if options[:list]
      res.delete('website')
      res.delete('description')
      res.delete('contact_email')
      res.delete('investment_amount')
      res.delete('equality_amount')
      res.delete('stage_of_funding')
      res.delete('created_at')
      res.delete('updated_at')
    elsif options[:investor_list]
      res.delete('website')
      res.delete('description')
      res.delete('contact_email')
      res.delete('investment_amount')
      res.delete('equality_amount')
      res.delete('stage_of_funding')
      res.delete('created_at')
      res.delete('updated_at')

      res[:evaluation] = get_evaluation
    else
      res[:team_members] = company_team_members.as_json(only: [:team_member_name, :c_level])
      res[:investment_amount] = investment_amount + invested_companies.sum(:investment)
      res[:equality_amount] = equality_amount + invested_companies.sum(:evaluation)
    end

    res[:has_image] = false
    if company_image
      res[:has_image] = true
    end

    if options[:investor_id]
      res[:is_interested] = interesting_companies.where(investor_id: options[:investor_id]).exists?
      res[:is_invested] = invested_companies.where(investor_id: options[:investor_id]).exists?
    end

    unless options[:my]
      res.delete('contact_email')
    end

    res.delete('image')
    res
  end

  def get_evaluation
    evaluation = 0

    if invested_companies.exists?
      investment = invested_companies.last
      evaluation = (investment.investment / (investment.evaluation * 0.01)).ceil
    elsif investment_amount and equality_amount
      evaluation = (investment_amount / (equality_amount * 0.01)).ceil
    end

    evaluation
  end

  def get_evaluation_on_date(date)
    evaluation = 0

    if created_at <= date
      # если создана раньше переданной даты, то эвалюация как минимум та, что в параметрах создания
      if investment_amount and equality_amount
        evaluation = (investment_amount / (equality_amount * 0.01)).ceil
      end

      # попробуем еще найти ивестиции на эту дату
      # берем все инвестиции с даты создания (она уже меньше чем переданная) до переданной,
      # нас интересует самая последняя их получившихся
      if invested_companies.exists?
        investment = invested_companies.where(created_at: created_at..date).order(created_at: :desc).first
        if investment
          evaluation = (investment.investment / (investment.evaluation * 0.01)).ceil
        end
      end
    end

    evaluation
  end
end

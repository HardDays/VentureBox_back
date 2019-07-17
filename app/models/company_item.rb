class CompanyItem < ApplicationRecord
  validates_presence_of :name, :company_id, :product_type, :price

  belongs_to :company
  belongs_to :country, optional: true
  has_one :company_item_image, dependent: :destroy
  has_many :company_item_tags, dependent: :destroy
  has_many :shopify_orders_counts, dependent: :destroy

  def as_json(options={})
    res = super(options)

    res.delete('image')
    res[:has_image] = false
    if company_item_image
      res[:has_image] = true
    end

    res.delete('shopify_id')

    res.delete('country_id')
    res[:country] = ""
    if country
      res[:country] = country.name
    end

    res[:company_name] = company.company_name
    res[:tags] = company_item_tags.pluck(:tag)
    res
  end
end

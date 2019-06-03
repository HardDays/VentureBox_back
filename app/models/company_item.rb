class CompanyItem < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :link_to_store
  validates :link_to_store, url: true, unless: Proc.new { |a| a.link_to_store.blank? }
  validates_presence_of :company_id

  belongs_to :company
  has_one :company_item_image, dependent: :destroy
  has_many :company_item_tags, dependent: :destroy

  def as_json(options={})
    res = super(options)

    res.delete('image')
    res[:has_image] = false
    if company_item_image
      res[:has_image] = true
    end

    res[:tags] = company_item_tags.pluck(:tag)
    res
  end
end

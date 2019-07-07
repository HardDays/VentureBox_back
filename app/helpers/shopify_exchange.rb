class ShopifyExchange
  shop_url = "https://#{ENV['SHOPIFY_API_KEY']}:#{ENV['SHOPIFY_PASSWORD']}@#{ENV['SHOPIFY_SHOP_NAME']}.myshopify.com"
  ShopifyAPI::Base.site = shop_url
  ShopifyAPI::Base.api_version = '2019-07'

  def self.create_product(company_item)
    begin
      new_product = ShopifyAPI::Product.new
      new_product.title = company_item.name
      new_product.product_type = company_item.product_type
      new_product.body_html = company_item.description
      new_product.tags = company_item.company_item_tags.pluck(:tag)
      new_product.country = company_item.country
      new_product.vendor = company_item.company.company_name
      new_product.save

      new_product_variant = new_product.variants[0]
      new_product_variant.inventory_policy = 'deny'
      new_product_variant.price = company_item.price
      new_product_variant.requires_shipping = false
      new_product_variant.save

      new_product_image = ShopifyAPI::Image.new
      new_product_image.attach_image(
        Base64.decode64(company_item.company_item_image.base64.gsub(/^data:image\/[a-z]+;base64,/, '')))
      new_product_image.prefix_options = { :product_id => new_product.id, :variant_ids => new_product_variant }

      new_product.images << new_product_image
      new_product.save

      new_product
    rescue => ex
      nil
    end
  end

  def self.update_product(company_item)
    shopify_product = ShopifyAPI::Product.find(company_item.shopify_id)

    shopify_product.images.each do |image|
      ShopifyAPI::Image.delete(image.id, product_id: company_item.shopify_id)
    end

    shopify_product.title = company_item.name
    shopify_product.product_type = company_item.product_type
    shopify_product.body_html = company_item.description
    shopify_product.tags = company_item.company_item_tags.pluck(:tag)
    shopify_product.country = company_item.country
    shopify_product.vendor = company_item.company.company_name
    shopify_product.save

    new_product_variant = shopify_product.variants[0]
    new_product_variant.inventory_policy = 'deny'
    new_product_variant.price = company_item.price
    new_product_variant.requires_shipping = false
    new_product_variant.save

    new_product_image = ShopifyAPI::Image.new
    new_product_image.attach_image(
      Base64.decode64(company_item.company_item_image.base64.gsub(/^data:image\/[a-z]+;base64,/, '')))
    new_product_image.prefix_options = { :product_id => shopify_product.id, :variant_ids => new_product_variant }

    shopify_product.images << new_product_image
    shopify_product.save

    shopify_product
  end
end

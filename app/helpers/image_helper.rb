module ImageHelper
  def self.resize(base64, width, height)
    blob = Base64.decode64(base64.gsub(/^data:image\/[a-z]+;base64,/, ''))

    image = MiniMagick::Image.read(blob)
    pure = MiniMagick::Tool::Convert.new
    pure << "-"
    pure.resize "#{width}x#{height}"
    pure << "-"
    res = pure.call(stdin: blob)

    resized_base64 = Base64.encode64(res)
    resized_base64
  end

  def self.resize_company_image(company_image_id, base64, width, height)
    width = width.to_i
    height = height.to_i
    resized_base64 = resize(base64, width, height)

    resized_image = ResizedCompanyImage.new(
      base64: resized_base64, width: width, height: height, company_image_id: company_image_id)
    resized_image.save

    resized_image
  end

  def self.resize_company_item_image(company_item_image_id, base64, width, height)
    width = width.to_i
    height = height.to_i
    resized_base64 = resize(base64, width, height)

    resized_image = ResizedCompanyItemImage.new(
      base64: resized_base64, width: width, height: height, company_item_image_id: company_item_image_id)
    resized_image.save

    resized_image
  end
end

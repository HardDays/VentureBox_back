class HttpUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless (value.starts_with? 'http://' or value.starts_with? 'https://')
      record.errors[attribute] << 'should start with http:// ot https://'
    end
  end
end

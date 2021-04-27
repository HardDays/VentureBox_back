source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# HERE 
ruby '2.6.3'

gem 'rails', '~> 5.2.3'
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.11'

# Reduces boot times through caching; required in config/boot.rb
# HERE
gem 'bootsnap', '>= 1.1.0', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.5'
end

group :development do
end

group :test do
  gem 'factory_bot_rails', '~> 4.0'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'faker'
  gem 'database_cleaner'
  gem 'timecop'
  gem "fantaskspec"
end


# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'swagger-docs'

gem 'rails_admin', '~> 1.3'
#HERE
# gem 'therubyracer', '~> 0.12.3'

gem 'valid_url'

gem 'mimemagic', github: 'mimemagicrb/mimemagic', ref: '01f92d86d15d85cfd0f20dabd025dcbd36a8a60f' 

gem 'httparty'

gem 'time_diff'

gem 'shopify_api'

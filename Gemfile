source 'https://rubygems.org'
ruby '2.5.0'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


gem 'rails', '~> 5.1.5'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'redis', '~> 4.0'

gem 'pg'
gem 'stream_rails'
gem 'devise'
gem 'omniauth-facebook', '~> 4.0'
gem 'omniauth-google-oauth2'
gem 'cancancan', '~> 2.0'
gem 'rolify'
gem 'activeadmin'
gem 'active_admin_jcrop'
gem 'carrierwave', '~> 1.0'
gem 'mini_magick'
gem 'bootstrap', '~> 4.0.0'
gem 'jquery-rails'
gem 'fog-aws'
gem 'loaf'
gem 'algoliasearch-rails'
gem "avatarly"
gem 'activeadmin_addons'
gem "font-awesome-rails"
gem 'active_admin_flat_skin'
gem 'social-share-button'
gem 'ratyrate'
gem 'rack-cors'
gem 'bulk_insert'


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

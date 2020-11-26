source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

## RAILS GEMS AND RELATED
gem 'rails', '~> 6.0.0'
gem 'puma', '~> 3.11'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'sass-rails', '~> 5'

## DATABASES ##
gem 'sqlite3', '~> 1.4'
gem "mysql2",  "< 0.5"

## JAVASCRIPT AND JSON
gem 'webpacker', '~> 4.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'

## CSS ##
gem 'bootstrap', '~> 4.3.1'
gem 'font-awesome-sass', '~> 5.6.1'

## TOOLS AND UTILITIES
gem 'simple_form', "4.1.0"
gem "devise", "4.7.0"
gem "config", "1.7.0"
gem "whenever", "1.0.0"
gem 'turnout', "2.5.0"
gem 'sucker_punch', '~> 2.0' # for async, quick jobs i.e logging

## ALMA ACCESS ##
gem "alma"
gem "httparty"
gem "jwt"

## SOAP ACCESS ##
gem "savon"
gem "lolsoap"

## Error Notification ##
gem 'exception_notification'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem "webmock"
  gem "sinatra"
end

group :development do
  gem "awesome_print", "1.8.0"
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do


  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'capybara-selenium'
  gem "cuprite"
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'

  gem "factory_bot_rails", "5.0.2"
  gem 'guard-rails',"0.8.1", require: false
  gem 'guard',"2.15.0"
  gem 'guard-minitest', "2.4.6"

  gem 'shoulda', "3.6.0"
  gem 'shoulda-matchers'
  gem 'shoulda-context'

  gem 'database_cleaner', "1.7.0"


  gem 'faker', "1.9.4"
  gem 'populator', git: "https://github.com/norikt/populator.git"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

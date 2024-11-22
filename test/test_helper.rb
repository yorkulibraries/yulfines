# encoding: ASCII-8BIT   # make sure this runs in binary mode
# frozen_string_literal: false

# some of the comments are in UTF-8
ENV['RAILS_ENV'] = 'test'
require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'
require 'factory_bot_rails'
require 'minitest/unit'
require 'mocha/minitest'
require 'database_cleaner/active_record'
require 'rails-controller-testing'
require 'vcr'

# Configure shoulda-matchers to use Minitest
require 'shoulda/matchers'

Rails::Controller::Testing.install

DatabaseCleaner.url_allowlist = [
  %r{.*test.*}
]
DatabaseCleaner.strategy = :truncation

include ActionDispatch::TestProcess

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
    #
    # Note: You'll currently still have to declare fixtures explicitly in integration tests
    # -- they do not yet inherit this setting

    # fixtures :all

    # Add more helper methods to be used by all tests here...
    include Warden::Test::Helpers
    Warden.test_mode!

    WebMock.allow_net_connect!
  
    include FactoryBot::Syntax::Methods

    setup do
      DatabaseCleaner.start
    end

    teardown do
      DatabaseCleaner.clean
    end
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionDispatch::TestProcess
  include ActionMailer::TestHelper

  def self.logged_in_with_user(&block)
    context "logged in user" do
      setup do
        @user = create :user
        sign_in @user
      end
      yield block
    end
  end
end


VCR.configure do |config|
  config.cassette_library_dir = 'test/cassettes'  # Directory to save cassettes
  config.hook_into :webmock                       # Use WebMock to intercept HTTP requests

  config.filter_sensitive_data('ALMA_API_KEY') { Settings.alma.api_key }
  config.filter_sensitive_data('ALMA_TEST_USER_PRIMARY_ID') { Settings.alma.test_user_primary_id }
  config.filter_sensitive_data('ALMA_TEST_USER_UNIV_ID') { Settings.alma.test_user_univ_id }
  config.filter_sensitive_data('ALMA_TEST_USER_PASSWORD') { Settings.alma.test_user_password }

  config.filter_sensitive_data('YPB_APPLICATION_PASSWORD') { Settings.ypb.application_password }
  config.filter_sensitive_data('YPB_APPLICATION_ID') { Settings.ypb.application_id }
  config.filter_sensitive_data('YPB_APPLICATION_NAME') { Settings.ypb.application_name }

  config.filter_sensitive_data('YPB_APPLICATION_LAW_PASSWORD') { Settings.ypb.application_law_password }
  config.filter_sensitive_data('YPB_APPLICATION_LAW_ID') { Settings.ypb.application_law_id }
  config.filter_sensitive_data('YPB_APPLICATION_LAW_NAME') { Settings.ypb.application_law_name }

  if !Settings.alma.test_text_to_filter.nil?
    Settings.alma.test_text_to_filter.each_with_index do |t,i|
      config.filter_sensitive_data("FILTERED_TEXT_#{i}") { t }
    end
  end
end

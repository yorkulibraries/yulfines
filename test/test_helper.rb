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

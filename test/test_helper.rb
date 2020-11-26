ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'


class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  include FactoryBot::Syntax::Methods

  ## CUSTOM ASSERTS ##
  def assert_dates_equal(date1, date2)
    date1.to_date.to_time == date2.to_date.to_time
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

        #post user_session_path "user[email]"    => user.email, "user[password]" => user.password
      end

      yield block
    end
  end
end

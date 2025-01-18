require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module YulFines
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.active_record.legacy_connection_handling = false

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = 'Eastern Time (US & Canada)'
    config.active_record.yaml_column_permitted_classes = [Date, ActiveSupport::TimeWithZone, Time,
                                                          ActiveSupport::TimeZone]

    # Using sucker punch to proccess logs and emails later
    config.active_job.queue_adapter = :sucker_punch

    # set delivery method to :smtp, :sendmail or :test
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = { address: ENV['SMTP_HOST'], port: ENV['SMTP_PORT'] }
    config.action_mailer.default_url_options = { host: ENV['HOST'] }
  end
end

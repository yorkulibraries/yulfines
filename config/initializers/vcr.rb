require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'test/cassettes'  # Directory to save cassettes
  config.hook_into :webmock                         # Use WebMock to intercept HTTP requests

  config.filter_sensitive_data('ALMA_API_KEY') { Settings.alma.api_key }

  config.filter_sensitive_data('YPB_APPLICATION_PASSWORD') { Settings.ypb.application_password }
  config.filter_sensitive_data('YPB_APPLICATION_ID') { Settings.ypb.application_id }
  config.filter_sensitive_data('YPB_APPLICATION_NAME') { Settings.ypb.application_name }

  config.filter_sensitive_data('YPB_APPLICATION_LAW_PASSWORD') { Settings.ypb.application_law_password }
  config.filter_sensitive_data('YPB_APPLICATION_LAW_ID') { Settings.ypb.application_law_id }
  config.filter_sensitive_data('YPB_APPLICATION_LAW_NAME') { Settings.ypb.application_law_name }
end

require 'alma'

# url: https://ocul-yor.alma.exlibrisgroup.com/mng/action/home.do?mode=ajax
Alma.configure do |config|
  config.apikey = Settings.alma.api_key
  config.region = Settings.alma.region
end

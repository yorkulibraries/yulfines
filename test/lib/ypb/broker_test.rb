require 'test_helper'
require 'vcr'

class Ypb::BrokerTest < ActiveSupport::TestCase
  YPB_TOKEN_LENGTH = 55

  Rails.application.routes.default_url_options[:host] = 'localhost'

  include Rails.application.routes.url_helpers

  should "get token" do
    transaction = create :payment_transaction, amount: 10.00
    record = create :payment_record, payment_transaction: transaction, user: transaction.user, amount: 8.00
    record2 = create :payment_record, payment_transaction: transaction, user: transaction.user, amount: 2.00
    transaction.records.reload

    postback_url = ypb_postback_url + "?id=#{transaction.id}"
    broker = Ypb::Broker.new_broker_instance(postback_url, false)
    
    VCR.use_cassette('ypb_broker_get_token') do
      token = broker.get_token transaction
      assert_not_nil token
      assert_equal YPB_TOKEN_LENGTH, token.length
    end
  end
end

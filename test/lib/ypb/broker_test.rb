require 'test_helper'

class Ypb::BrokerTest < ActiveSupport::TestCase

  should "get token somehow" do
    transaction = create :payment_transaction, amount: 10.00
    record = create :payment_record, payment_transaction: transaction, user: transaction.user, amount: 8.00
    record2 = create :payment_record, payment_transaction: transaction, user: transaction.user, amount: 2.00

    transaction.records.reload

    root_url = "https://library.yorku.ca/fines"
    broker = Ypb::Broker.new wsdl: Settings.ypb.wsdl_url, success_url: root_url, failure_url: root_url, log: true
    #transaction.id = Time.now.to_i # this is done so that YPB doesn't bitch

    token_id = broker.get_token transaction

    assert_not_nil token_id

  end



end

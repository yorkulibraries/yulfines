require 'test_helper'

class TransactionLogTest < ActiveSupport::TestCase

  should "create a valid transaction log" do
    tlog = build(:transaction_log)

    assert_difference "TransactionLog.count" do
      tlog.save
    end
  end

  should "not create an invalid transaction log" do
    assert ! build(:transaction_log, yorku_id: nil).valid?, "YorkU ID is required"
    assert ! build(:transaction_log, logged_at: nil).valid?, "Logged At is required"
    assert ! build(:transaction_log, message: nil).valid?, "Message is required"
  end

  should "create set process to other if it wasn't supplied" do
    tlog = build(:transaction_log, process_name: nil)
    tlog.save
    assert_not_nil tlog.process_name
    assert_equal TransactionLog::PROCESS_OTHER, tlog.process_name
  end

  should "create a valid TransactionLog using helper method" do
    assert_difference "TransactionLog.count" do
      TransactionLog.log message: "Woot", yorku_id: "Yea", alma_fee_id: "soso",
                         logged_at: Time.now, process_name: TransactionLog::ALMA_LOAD_FEES
    end
  end
end

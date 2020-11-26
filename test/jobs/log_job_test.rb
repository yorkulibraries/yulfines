require 'test_helper'

class LogJobTest < ActiveJob::TestCase

  should "create a log entry" do
    logged_time = Time.now

    assert_difference "TransactionLog.count" do
      LogJob.perform_now message: "test",
                           yorku_id: "123",
                           alma_fee_id: "123",
                           transaction_id: 1,
                           ypb_transaction_id: "ypb_2",
                           logged_at: logged_time,
                           process_name: TransactionLog::PROCESS_OTHER,
                           additional_changes: nil
    end

    last = TransactionLog.last
    assert_equal "test", last.message
    assert_equal "123", last.yorku_id
    assert_equal "123", last.alma_fee_id
    assert_equal logged_time, last.logged_at
    assert_equal 1, last.transaction_id
    assert_equal "ypb_2", last.ypb_transaction_id
    assert_equal TransactionLog::PROCESS_OTHER, last.process_name
  end
end

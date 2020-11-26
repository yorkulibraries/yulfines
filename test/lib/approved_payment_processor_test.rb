require 'test_helper'

class ApprovedPaymentProcessorTest < ActiveSupport::TestCase

  should "create a new PaymentProcessor with Mock or Default One" do
    payment_processor = ApprovedPaymentProcessor.new MockFeeProcessor

    assert_not_nil payment_processor
    assert_equal payment_processor.fee_processor.class.name, MockFeeProcessor.to_s

    pp2 = ApprovedPaymentProcessor.new
    assert_not_nil pp2.fee_processor
    assert_equal pp2.fee_processor.class.to_s, Alma::FeeProcessor.to_s
  end

  should "create an payment processor with a url" do
    processor = ApprovedPaymentProcessor.new url: "some_url"
    assert_equal processor.fee_url, "some_url"
  end

  should "pay fee and mark transaction, records and alma_fee as paid" do
    t = create :payment_transaction, status: PaymentTransaction::STATUS_APPROVED
    record = create :payment_record, payment_transaction: t
    fee = record.fee


    # precondition
    assert ! fee.paid?
    assert t.status == PaymentTransaction::STATUS_APPROVED
    assert record.status == PaymentRecord::STATUS_PROCESSING

    # action
    processor = ApprovedPaymentProcessor.new MockFeeProcessor # Make sure to use this
    processor.process_approved_transactions

    #postcodition
    fee.reload
    t.reload
    record.reload

    assert fee.paid?
    assert t.paid?
    assert record.paid?
  end

  should "pay multiple fees if present" do
    t = create :payment_transaction, status: PaymentTransaction::STATUS_APPROVED
    record1 = create :payment_record, payment_transaction: t
    record2 = create :payment_record, payment_transaction: t

    # action
    processor = ApprovedPaymentProcessor.new MockFeeProcessor # Make sure to use this
    processor.process_approved_transactions

    # post codition
    t.reload
    record1.reload
    record2.reload

    assert t.paid?
    assert record1.paid?
    assert record2.paid?
  end

  should "pay multiple transactions" do
    transactions = []
    3.times do
      t = create :payment_transaction, status: PaymentTransaction::STATUS_APPROVED
      record1 = create :payment_record, payment_transaction: t
      transactions << t
    end

    # action
    processor = ApprovedPaymentProcessor.new MockFeeProcessor # Make sure to use this
    assert transactions.size, processor.process_approved_transactions

    transactions.each do |t|
      t.reload
      assert t.paid?
    end
  end

  ## THE BIG ONE, Multiple thread access to the same resource
  should "Only allow access one process (internal/external)" do
    transactions = []
    3.times do
      t = create :payment_transaction, status: PaymentTransaction::STATUS_APPROVED
      record1 = create :payment_record, payment_transaction: t
      transactions << t
    end

    processor_1 = ApprovedPaymentProcessor.new MockFeeProcessor
    processor_1.fee_processor = MockFeeProcessor.new(1)

    processor_2 = ApprovedPaymentProcessor.new MockFeeProcessor
    processor_2.fee_processor = MockFeeProcessor.new(0)

    Thread.new {
      processor_1.process_approved_transactions
    }

    assert_equal 3,  processor_2.process_approved_transactions

  end

end

### MOCK FEE PROCESSOR, for testing

class MockFeeProcessor

  def initialize(sleep_interval = 1)
    @sleep_interval = sleep_interval
  end

  def pay_fee!(record)
    sleep @sleep_interval
    return true
  end
end

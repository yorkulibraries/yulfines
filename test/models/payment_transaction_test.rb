require 'test_helper'

class PaymentTransactionTest < ActiveSupport::TestCase

  should "be able to create a payment transaction and generate uid" do
    transaction = build :payment_transaction, status: PaymentTransaction::STATUS_NEW

    assert_difference "PaymentTransaction.count" do
      transaction.save
    end

    assert_not_nil transaction.order_id
    assert transaction.order_id.start_with? "#{transaction.id}-"
    assert_equal PaymentTransaction::STATUS_NEW, transaction.status
  end

  should "not be able to create an invalid Payment transaction" do
    assert ! build(:payment_transaction, yorku_id: nil).valid?
    assert ! build(:payment_transaction, user: nil).valid?
    assert ! build(:payment_transaction, status: nil).valid?

    ## ensure status provided is proper
    assert ! build(:payment_transaction, status: "dfjaldjfa").valid?, "Status should be one of the defined"
  end


  should "mark transaction as paid only if status approved and all records paid" do
    t = create :payment_transaction, status: PaymentTransaction::STATUS_APPROVED
    record = create :payment_record, payment_transaction: t
    record.mark_paid!

    assert ! t.paid?
    t.mark_paid!
    t.reload
    assert t.paid?

    t2 = create :payment_transaction
    t2.status = PaymentTransaction::STATUS_PROCESSING
    record2 = create :payment_record, payment_transaction: t2
    record2.mark_paid!
    t.reload

    assert ! t2.paid?
    t2.mark_paid!

    t.reload
    assert ! t2.paid?
  end

  should "mark transaction as PAID partial if not all records have paid successfully" do
    t = create :payment_transaction, status: PaymentTransaction::STATUS_APPROVED
    record = create :payment_record, payment_transaction: t
    record.mark_paid!
    record2 = create :payment_record, payment_transaction: t
    record2.mark_rejected!

    assert ! t.paid?
    t.mark_paid!

    t.reload
    assert ! t.paid?
    assert t.paid_partial?
  end

  should "mark transaction as REJECTED if  all records were rejected" do
    t = create :payment_transaction, status: PaymentTransaction::STATUS_APPROVED
    record = create :payment_record, payment_transaction: t
    record.mark_rejected!
    record2 = create :payment_record, payment_transaction: t
    record2.mark_rejected!

    assert ! t.paid?
    t.mark_paid!
    t.reload
    assert ! t.paid?
    assert t.rejected_by_alma?
  end

  should "return proper flags based on values" do
    assert create(:payment_transaction, status: PaymentTransaction::STATUS_APPROVED).approved?
    assert create(:payment_transaction, status: PaymentTransaction::STATUS_DECLINED).declined?
    assert create(:payment_transaction, status: PaymentTransaction::STATUS_CANCELLED).cancelled?
    assert create(:payment_transaction, status: PaymentTransaction::STATUS_PAID).paid?
    assert create(:payment_transaction, status: PaymentTransaction::STATUS_PAID_PARTIAL).paid_partial?
    assert create(:payment_transaction, status: PaymentTransaction::STATUS_REJECTED_BY_ALMA).rejected_by_alma?
    assert create(:payment_transaction, status: PaymentTransaction::STATUS_YPB_DECLINED).ypb_incomplete?
    assert create(:payment_transaction, status: PaymentTransaction::STATUS_YPB_CANCELLED).ypb_incomplete?
  end

  should "only return transactions odler than 15 minutes" do
    new_t = create :payment_transaction
    assert_equal 0, PaymentTransaction.older_than.size

    old_t = create :payment_transaction, created_at: 20.minutes.ago

    assert_equal 1, PaymentTransaction.older_than.size
    assert_equal old_t.id, PaymentTransaction.older_than.first.id    

  end
end

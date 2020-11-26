require 'test_helper'

class Alma::FeeTest < ActiveSupport::TestCase

  should "be able to create an alma fee" do
    fee = build(:alma_fee)

    assert_difference "Alma::Fee.count" do
      fee.save
    end
  end


  should "return true if fee has been paid" do
    fee = create :alma_fee, fee_status: "ACTIVE"

    assert ! fee.paid?

    fee.update fee_status: Alma::Fee::STATUS_PAID

    assert fee.paid?

  end

  should "return true of payment is pending(processing) but alma fee  has been paid yet" do
    user = create :user
    fee = create :alma_fee, fee_status: "ACTIVE", yorku_id: user.yorku_id
    assert ! fee.payment_pending?

    record = create :payment_record, user:user, fee: fee
    record.mark_abandonned!
    assert ! fee.payment_pending?

    create :payment_record, user: user, fee: fee, status: PaymentRecord::STATUS_PROCESSING
    assert fee.payment_pending?
  end

  should "make fee as stale and return proper flag" do
    user = create :user
    fee = create :alma_fee, fee_status: "ACTIVE", yorku_id: user.yorku_id

    assert ! fee.stale?
    fee.mark_as_stale!

    fee.reload
    assert fee.stale?
  end

  should "return active fees only" do
    create :alma_fee, fee_status: "ACTIVE"
    create :alma_fee, fee_status: "ACTIVE_OVERDUE"
    create :alma_fee, fee_status: Alma::Fee::STATUS_STALE
    create :alma_fee, fee_status: Alma::Fee::STATUS_PAID

    assert_equal 2, Alma::Fee.active.size
    assert_equal "ACTIVE", Alma::Fee.active.first.fee_status
    assert_equal "ACTIVE_OVERDUE", Alma::Fee.active.last.fee_status
  end
end

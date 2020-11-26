require 'test_helper'

class PaymentRecordTest < ActiveSupport::TestCase

  should "be able to create a payment record" do
    record = build :payment_record

    assert_difference "PaymentRecord.count" do
      record.save
    end
  end

  should "not be able to create an invalid Payment Record" do
    assert ! build(:payment_record, amount: nil).valid?
    assert ! build(:payment_record, user: nil).valid?
    assert ! build(:payment_record, fee: nil).valid?

    ## ensure fee belongs to user
    assert ! build(:payment_record, user: create(:user), fee: create(:alma_fee)).valid?, "Fee should belong to user"
  end

  should "update yorku id from user and alma_fee from fee" do
    user = create :user
    fee = create :alma_fee, yorku_id: user.yorku_id

    record = build :payment_record, user: user, fee: fee, yorku_id: nil, alma_fee_id: nil
    assert_nil record.yorku_id
    assert_nil record.alma_fee_id

    record.save

    assert_equal fee.fee_id, record.alma_fee_id
    assert_equal user.yorku_id, record.yorku_id
  end

  should "set status to processing after create" do
    record = build :payment_record
    assert record.status != PaymentRecord::STATUS_PROCESSING
    record.save
    assert_equal PaymentRecord::STATUS_PROCESSING, record.status
  end

  should "copy fee details after create" do
    record = build :payment_record
    assert_nil record.fee_owner_id

    record.save

    assert_equal record.fee_owner_id, record.fee.owner_id
    assert_equal record.fee_owner_description, record.fee.owner_description
    assert_equal record.fee_item_title, record.fee.item_title
    assert_equal record.fee_item_barcode, record.fee.item_barcode
  end


  should "mark record as paid only if status processing" do
    record = create :payment_record, status: PaymentRecord::STATUS_PROCESSING
    assert ! record.paid?
    record.mark_paid!
    assert record.paid?
    assert_equal Alma::Fee::STATUS_PAID, record.fee.fee_status

    record2 = create :payment_record
    record2.status = PaymentRecord::STATUS_REJECTED

    assert ! record2.paid?
    record2.mark_paid!
    assert ! record2.paid?
  end

  should "mark record as rejected only if status processing" do
    record = create :payment_record, status: PaymentRecord::STATUS_PROCESSING
    assert ! record.rejected?

    error_msg = "401166 - Unknown something"
    error_code = "40166"
    error_tacking = "12323"

    record.mark_rejected! error_code: error_code, error_message: error_msg, tracking_id: error_tacking
    assert record.rejected?
    assert_equal error_msg, record.alma_fines_rejected_error_reason
    assert_equal error_code, record.alma_fines_rejected_error_code
    assert_equal error_tacking, record.alma_fines_rejected_error_tracking_id

    record2 = create :payment_record
    record2.status = PaymentRecord::STATUS_PAID

    assert ! record2.rejected?
    record2.mark_rejected!
    assert ! record2.rejected?
  end

end

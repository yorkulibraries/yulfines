require 'test_helper'

class YpbPostbackControllerTest < ActionDispatch::IntegrationTest
  setup do
    @transaction = create :payment_transaction, amount: 10.00, status: PaymentTransaction::STATUS_PROCESSING, uid: "123"
    record = create :payment_record, payment_transaction: @transaction, user: @transaction.user, amount: 8.00
    record2 = create :payment_record, payment_transaction: @transaction, user: @transaction.user, amount: 2.00

    @params =  {
              tokenid: @transaction.uid,
              orderid: @transaction.order_id,
              yporderid: @transaction.order_id,
              status: PaymentTransaction::STATUS_APPROVED,
              message: "Some message",
              cardtype: "V",
              amount: @transaction.amount,
              authcode: "20303003",
              refnum: "20320320",
              txn_num: "dlfjasdljf",
              cardholder: "John Smith",
              cardnum: "4242****4242"
            }
  end

  should "APPROVED: update a transaction with the details from YPB Postback" do
    post ypb_postback_path, params: @params
    assert_response :redirect
    assert_redirected_to transaction_path(@transaction)

    @transaction.reload
    assert_not_nil @transaction.ypb_transaction_approved_at
    assert_equal @params[:yporderid], @transaction.yporderid
    assert_equal @params[:status], @transaction.status
    assert_equal @params[:message], @transaction.message
    assert_equal @params[:cardtype], @transaction.cardtype
    assert_equal @params[:amount], @transaction.amount
    assert_equal @params[:authcode], @transaction.authcode
    assert_equal @params[:refnum], @transaction.refnum
    assert_equal @params[:txn_num], @transaction.txn_num
    assert_equal @params[:cardholder], @transaction.cardholder
    assert_equal @params[:cardnum], @transaction.cardnum
  end

  should "DECLINED: update a transaction with the proper details from YPB Postback" do
    @params[:status] = PaymentTransaction::STATUS_DECLINED

    post ypb_postback_path, params: @params
    assert_response :redirect
    assert_redirected_to transaction_path(@transaction)

    @transaction.reload
    assert_not_nil @transaction.ypb_transaction_declined_at
    assert_equal @params[:yporderid], @transaction.yporderid
    assert_equal @params[:status], @transaction.status
    assert_equal @params[:message], @transaction.message
    assert_equal @params[:cardtype], @transaction.cardtype
    assert_equal @params[:amount], @transaction.amount
    assert_equal @params[:authcode], @transaction.authcode
    assert_equal @params[:refnum], @transaction.refnum
    assert_equal @params[:txn_num], @transaction.txn_num
    assert_equal @params[:cardholder], @transaction.cardholder
    assert_equal @params[:cardnum], @transaction.cardnum
  end

end

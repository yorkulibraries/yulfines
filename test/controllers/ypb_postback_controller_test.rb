require 'test_helper'
require 'webmock/minitest'

class YpbPostbackControllerTest < ActionDispatch::IntegrationTest
  APPROVED_RECEIPT_SAMPLE_FILE = "example_receipt_page_approved.html"
  CANCELLED_RECEIPT_SAMPLE_FILE = "example_receipt_page_cancelled.html"
  DECLINED_RECEIPT_SAMPLE_FILE = "example_receipt_page_declined.html"

  should "APPROVED: update a transaction with the details from YPB Postback" do
    @transaction = create :payment_transaction, amount: 10.00, status: PaymentTransaction::STATUS_PROCESSING, uid: "123"
    record = create :payment_record, payment_transaction: @transaction, user: @transaction.user, amount: 8.00
    record2 = create :payment_record, payment_transaction: @transaction, user: @transaction.user, amount: 2.00

    @params =  {
      tokenid: @transaction.uid,
      id: @transaction.id
    }

    html =  file_fixture(APPROVED_RECEIPT_SAMPLE_FILE).read

    # mock the receipt URL to return the APPROVED receipt html 
    url = "#{Settings.ypb.receipt_page_url}?tokenid=#{@transaction.uid}"
    stub_request(:get, url).to_return(
      status: 200,
      body: html
    )

    post ypb_postback_path, params: @params
    assert_response :redirect
    assert_redirected_to transaction_path(@transaction)

    # verify that @transaction is updated with the value extracted from the Mocked receipt
    @transaction.reload
    assert_not_nil @transaction.ypb_transaction_approved_at
    assert_equal '1-1732127978', @transaction.order_id
    assert_equal '1-173212797800000000000000111436', @transaction.yporderid
    assert_equal 'T32062', @transaction.authcode
    assert_equal '660194530012670130', @transaction.refnum
    assert_equal 'Transaction Approved', @transaction.message
    assert_equal PaymentTransaction::STATUS_APPROVED, @transaction.status
    assert_equal 0.04, @transaction.amount
    assert_equal 'fasdfd', @transaction.cardholder
    assert_equal '545454**5454', @transaction.cardnum
    assert_equal 'M', @transaction.cardtype
  end

  should "DECLINED: update a transaction with the proper details from YPB Postback" do
    @transaction = create :payment_transaction, amount: 10.00, status: PaymentTransaction::STATUS_PROCESSING, uid: "123"
    record = create :payment_record, payment_transaction: @transaction, user: @transaction.user, amount: 8.00
    record2 = create :payment_record, payment_transaction: @transaction, user: @transaction.user, amount: 2.00

    @params =  {
      tokenid: @transaction.uid,
      id: @transaction.id
    }

    html =  file_fixture(DECLINED_RECEIPT_SAMPLE_FILE).read

    # mock the receipt URL to return the APPROVED receipt html 
    url = "#{Settings.ypb.receipt_page_url}?tokenid=#{@transaction.uid}"
    stub_request(:get, url).to_return(
      status: 200,
      body: html
    )

    post ypb_postback_path, params: @params
    assert_response :redirect
    assert_redirected_to transaction_path(@transaction)

    # verify that @transaction is updated with the value extracted from the Mocked receipt
    @transaction.reload
    assert_equal '14-1732127083', @transaction.order_id
    assert_equal '14-173212708300000000000000111432', @transaction.yporderid
    assert_equal '000000', @transaction.authcode
    assert_equal '660194530012670090', @transaction.refnum
    assert_equal 'Transaction Declined', @transaction.message
    assert_equal PaymentTransaction::STATUS_DECLINED, @transaction.status
    assert_equal 0.01, @transaction.amount
    assert_equal 'sdfasdf', @transaction.cardholder
    assert_equal '545454**5454', @transaction.cardnum
    assert_equal 'M', @transaction.cardtype
  end

  should "CANCELLED: update a transaction with the proper details from YPB Postback" do
    @transaction = create :payment_transaction, amount: 10.00, status: PaymentTransaction::STATUS_PROCESSING, uid: "123"
    record = create :payment_record, payment_transaction: @transaction, user: @transaction.user, amount: 8.00
    record2 = create :payment_record, payment_transaction: @transaction, user: @transaction.user, amount: 2.00

    @params =  {
      tokenid: @transaction.uid,
      id: @transaction.id
    }

    html =  file_fixture(CANCELLED_RECEIPT_SAMPLE_FILE).read

    # mock the receipt URL to return the APPROVED receipt html 
    url = "#{Settings.ypb.receipt_page_url}?tokenid=#{@transaction.uid}"
    stub_request(:get, url).to_return(
      status: 200,
      body: html
    )

    post ypb_postback_path, params: @params
    assert_response :redirect
    assert_redirected_to transaction_path(@transaction)

    # verify that @transaction is updated with the value extracted from the Mocked receipt
    @transaction.reload
    assert_equal '10-1732126225', @transaction.order_id
    assert_equal '10-173212622500000000000000111428', @transaction.yporderid
    assert_equal PaymentTransaction::STATUS_CANCELLED, @transaction.status
  end

end

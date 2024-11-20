require 'test_helper'

class Ypb::ReceiptParserTest < ActiveSupport::TestCase

  APPROVED_RECEIPT_SAMPLE_FILE = "example_receipt_page_approved.html"
  CANCELLED_RECEIPT_SAMPLE_FILE = "example_receipt_page_cancelled.html"
  DECLINED_RECEIPT_SAMPLE_FILE = "example_receipt_page_declined.html"

  should "parse APPROVED receipt" do
    html =  file_fixture(APPROVED_RECEIPT_SAMPLE_FILE).read

    parser = Ypb::ReceiptParser.new

    receipt = parser.parse_receipt html

    assert_equal '1-1732127978', receipt[:orderid]
    assert_equal '1-173212797800000000000000111436', receipt[:ypborderid]
    assert_equal 'T32062', receipt[:authcode]
    assert_equal '660194530012670130', receipt[:refnum]

    assert_equal 'Transaction Approved', receipt[:message]
    assert_equal PaymentTransaction::STATUS_APPROVED, receipt[:status]
    assert_equal '0.04', receipt[:amount]

    assert_equal 'fasdfd', receipt[:cardholder]
    assert_equal '545454**5454', receipt[:cardnum]
    assert_equal 'M', receipt[:cardtype]
  end

  should "parse CANCELLED receipt" do
    html =  file_fixture(CANCELLED_RECEIPT_SAMPLE_FILE).read

    parser = Ypb::ReceiptParser.new

    receipt = parser.parse_receipt html

    assert_equal '10-1732126225', receipt[:orderid]
    assert_equal '10-173212622500000000000000111428', receipt[:ypborderid]

    assert_equal PaymentTransaction::STATUS_CANCELLED, receipt[:status]
  end

  should "parse DECLINED receipt" do
    html =  file_fixture(DECLINED_RECEIPT_SAMPLE_FILE).read

    parser = Ypb::ReceiptParser.new

    receipt = parser.parse_receipt html

    assert_equal '14-1732127083', receipt[:orderid]
    assert_equal '14-173212708300000000000000111432', receipt[:ypborderid]
    assert_equal '000000', receipt[:authcode]
    assert_equal '660194530012670090', receipt[:refnum]

    assert_equal 'Transaction Declined', receipt[:message]
    assert_equal PaymentTransaction::STATUS_DECLINED, receipt[:status]
    assert_equal '0.01', receipt[:amount]

    assert_equal 'sdfasdf', receipt[:cardholder]
    assert_equal '545454**5454', receipt[:cardnum]
    assert_equal 'M', receipt[:cardtype]
  end

  should "parse cancelled or declined page properly" do
    cancelled_html =  file_fixture(CANCELLED_RECEIPT_SAMPLE_FILE).read
    declined_html =  file_fixture(DECLINED_RECEIPT_SAMPLE_FILE).read

    parser = Ypb::ReceiptParser.new

    receipt = parser.parse_receipt cancelled_html
    assert_equal PaymentTransaction::STATUS_CANCELLED, receipt[:status]

    receipt = parser.parse_receipt declined_html
    assert_equal PaymentTransaction::STATUS_DECLINED, receipt[:status]
  end

  should "parse status correctly" do
    parser = Ypb::ReceiptParser.new

    assert_equal PaymentTransaction::STATUS_APPROVED, parser.parse_status(Ypb::ReceiptParser::STATUS_MESSAGE_APPROVED)
    assert_equal PaymentTransaction::STATUS_DECLINED, parser.parse_status(Ypb::ReceiptParser::STATUS_MESSAGE_DECLINED)
    assert_equal PaymentTransaction::STATUS_CANCELLED, parser.parse_status(Ypb::ReceiptParser::STATUS_MESSAGE_CANCELLED)
    assert_equal 'garbage', parser.parse_status('garbage')
  end

  should "copy values from receipt to transaction" do
    html =  file_fixture(APPROVED_RECEIPT_SAMPLE_FILE).read

    parser = Ypb::ReceiptParser.new

    receipt = parser.parse_receipt html

    txn = parser.copy_receipt_to_transaction receipt, PaymentTransaction.new

    assert_equal txn.order_id, receipt[:orderid]
    assert_equal txn.yporderid, receipt[:ypborderid]
    assert_equal txn.authcode, receipt[:authcode]
    assert_equal txn.refnum, receipt[:refnum]

    assert_equal txn.message, receipt[:message]
    assert_equal txn.status, receipt[:status]
    assert_equal txn.amount.to_s, receipt[:amount]

    assert_equal txn.cardholder, receipt[:cardholder]
    assert_equal txn.cardnum, receipt[:cardnum]
    assert_equal txn.cardtype, receipt[:cardtype]
  end
end

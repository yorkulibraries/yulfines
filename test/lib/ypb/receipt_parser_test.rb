require 'test_helper'

class Ypb::ReceiptParserTest < ActiveSupport::TestCase

  APPROVED_RECEIPT_SAMPLE_FILE = "example_receipt_page_approved.html"
  CANCELLED_RECEIPT_SAMPLE_FILE = "example_receipt_page_cancelled.html"
  DECLINED_RECEIPT_SAMPLE_FILE = "example_receipt_page_declined.html"

  ## THESE HAVE TO MATCH THE VALUES ON THE PAGE, SO THAT WE CAN TEST EXTRACTION PROPERLY ##
  RECEIPT_SAMPLE_VALUES = {
    tokenid: "j7pxxpr7PtVhmDQl6YjTEB8z_1FT1qDkfOocotuveY-1g9VRZk_O-A2",
    orderid: "15-1569587859 ",
    yporderid: "15-156958785900000000000000018738",
    authcode: "967147",
    refnum: "660148420014921370",
    status: PaymentTransaction::STATUS_APPROVED,

    message: "APPROVED           *                    =",
    amount: "1.01",

    #txn_num: "NOT NEEDED",
    cardtype: "V",
    cardholder: "John Smith",
    cardnum: "4242***4242"
  }

  should "parse receipt" do
    html =  file_fixture(APPROVED_RECEIPT_SAMPLE_FILE).read

    parser = Ypb::ReceiptParser.new

    receipt = parser.parse_receipt html


    assert_equal RECEIPT_SAMPLE_VALUES[:yporderid], receipt[:yporderid]
    assert_equal RECEIPT_SAMPLE_VALUES[:authcode], receipt[:authcode]
    assert_equal RECEIPT_SAMPLE_VALUES[:refnum], receipt[:refnum]

    assert_equal RECEIPT_SAMPLE_VALUES[:message], receipt[:message]
    assert_equal RECEIPT_SAMPLE_VALUES[:status], receipt[:status]
    assert_equal RECEIPT_SAMPLE_VALUES[:amount], receipt[:amount]

    assert_equal RECEIPT_SAMPLE_VALUES[:cardholder], receipt[:cardholder]
    assert_equal RECEIPT_SAMPLE_VALUES[:cardnum], receipt[:cardnum]
    assert_equal RECEIPT_SAMPLE_VALUES[:cardtype], receipt[:cardtype]

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
    assert_equal PaymentTransaction::STATUS_CANCELLED, parser.parse_status('dfajldsf')
  end

  should "copy values from receipt to transaction" do
    html =  file_fixture(APPROVED_RECEIPT_SAMPLE_FILE).read

    parser = Ypb::ReceiptParser.new

    receipt = parser.parse_receipt html

    txn = parser.copy_receipt_to_transaction receipt, PaymentTransaction.new

    assert_equal txn.yporderid, receipt[:yporderid]
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

class Ypb::ReceiptParser

  STATUS_MESSAGE_APPROVED="TRANSACTION APPROVED"
  STATUS_MESSAGE_DECLINE="TRANSACTION DECLINE"
  STATUS_MESSAGE_DECLINED="TRANSACTION DECLINED"
  STATUS_MESSAGE_CANCELLED="TRANSACTION CANCELLED"

  REGEX_AUTHCODE =  /<h4>Auth Code:<\/h4><h6[^>]*>([0-9a-zA-Z]+)<\/h6>/
  REGEX_ORDERID =  /<h4>Client Order Id:<\/h4><h6[^>]*>([^<>]*)<\/h6>/
  REGEX_YPORDERID =  /<h4>YPB Order Id:<\/h4><h6[^>]*>([^<>]*)<\/h6>/
  REGEX_STATUS =  />([A-Z\/ ]+)<\/h3>/
  REGEX_REFNUM =  /<h4>Reference Number:<\/h4><h6[^>]*>([0-9]+)<\/h6>/
  REGEX_AMOUNT =  /<h4>Transaction Amount:<\/h4><h6[^>]*>([0-9]+\.[0-9][0-9])<\/h6>/
  REGEX_MESSAGE =  /<h4>Message:<\/h4><h6[^>]*>([^<>]*)<\/h6>/

  REGEX_CARDTYPE =  /<h4>Card Type:<\/h4><h6[^>]*>([0-9a-zA-Z]+)<\/h6>/
  REGEX_CARDHOLDER =  /<h4>Card Holder:<\/h4><h6[^>]*>([^<>]*)<\/h6>/
  REGEX_CARDNUM =  /<h4>Card Number:<\/h4><h6[^>]*>([^<>]*)<\/h6>/

  def parse_receipt(html)
    return if html.blank?

    doc = Nokogiri::HTML(html)

    receipt = {}

    receipt[:authcode] = get_val html, REGEX_AUTHCODE
    receipt[:orderid] = get_val(html, REGEX_ORDERID)
    receipt[:ypborderid] = get_val html, REGEX_YPORDERID
    receipt[:message] =  get_val html, REGEX_MESSAGE
    receipt[:refnum] = get_val html, REGEX_REFNUM
    receipt[:amount] =  get_val html, REGEX_AMOUNT
    receipt[:cardtype] =  get_val html, REGEX_CARDTYPE
    receipt[:cardholder] = get_val html, REGEX_CARDHOLDER
    receipt[:cardnum] = get_val html, REGEX_CARDNUM
    receipt[:status] = parse_status get_val(html, REGEX_STATUS)

    return receipt
  end

  def copy_receipt_to_transaction(receipt, txn)
    return if receipt == nil || txn == nil

    txn.order_id = receipt[:orderid]
    txn.yporderid = receipt[:ypborderid]
    txn.status = receipt[:status]
    txn.message = receipt[:message]
    txn.cardtype = receipt[:cardtype]
    txn.authcode = receipt[:authcode]
    txn.refnum = receipt[:refnum]
    txn.cardholder = receipt[:cardholder]
    txn.cardnum = receipt[:cardnum]
    txn.amount = receipt[:amount]

    return txn
  end


  def get_val(html, regexp)
    return "" if html.blank?
    return html.scan(regexp).first.first.strip rescue nil
  end

  def parse_status(status)
    declined = ['TRANSACTION DECLINE', 'TRANSACTION DECLINED', 
      'TRANSACTION DECLINE/INCOMPLETE','TRANSACTION DECLINED/INCOMPLETE']
    cancelled = ['TRANSACTION CANCELLED', 'TRANSACTION CANCELLED/INCOMPLETE']
    approved = ['TRANSACTION APPROVED']
    
    return PaymentTransaction::STATUS_DECLINED if declined.include?(status)
    return PaymentTransaction::STATUS_CANCELLED if cancelled.include?(status)
    return PaymentTransaction::STATUS_APPROVED if approved.include?(status)

    status
  end
end

require 'net/http'

class Alma::FeeProcessor
  attr_accessor :fee_url, :response_code, :error_code, :error_message, :tracking_id

  def initialize(url: Settings.alma.api.fee_url)
    #@record = payment_record
    #@fee_url = prepare_url(url, @record.fee.fee_id, @record.yorku_id) if url != nil
    @url_template = url
  end

  def pay_fee!(record)
    return if @url_template == nil || record == nil

    @record = record

    fee_url =  prepare_url(@url_template, @record)

    response = HTTParty.post(fee_url, query: pay_params(record), headers: headers)
    @response_code = response.code

   if @response_code.to_s == "200"
     return true
   else
     json = JSON.parse response.body
     parse_error json
     return false
   end
  end


  def pay_params(record)

    params = {
      user_type_id: "all_unique",
      op: "pay",
      amount: record.amount,
      #method: "CREDIT_CARD",
      method: pay_method(record),
      reason: "Paying The Fee",
      comment: "#{record.user.name} is paying via YU Payment Broker",
      external_transaction_id: record.payment_transaction.refnum
    }
  end

  def pay_method(record)
    return "CREDIT_CARD" if record == nil || record.payment_transaction == nil
    t = record.payment_transaction

    if t.cardtype.try(:downcase) == "m"
      return "CHECK"
    else
      return "CREDIT_CARD"
    end

  end

  def prepare_url(url, record)

    fee_id = record.fee.fee_id
    user_id = record.yorku_id

    with_fee = url.sub("{{fee_id}}", fee_id.to_s)
    return with_fee.sub("{{user_primary_id}}", user_id.to_s)
  end

  def headers
     { "Authorization": "apikey #{Settings.alma.api_key}",
     "Accept": "application/json",
     "Content-Type": "application/json" }
   end

   def parse_error(json_response)
     if json_response["errorList"] && json_response["errorList"]["error"]
        @error_code = json_response["errorList"]["error"].first["errorCode"]
        @error_message = json_response["errorList"]["error"].first["errorMessage"]
        @tracking_id = json_response["errorList"]["error"].first["trackingId"]
     end
   end
end

require 'savon'

class Ypb::Broker

  GET_TOKEN_OP = :get_token
  ORDER_INITIALIZE_OP = :order_initialize
  ITEMS_INITIALIZE_OP = :items_initialize


  def initialize(wsdl: nil, success_url: nil, failure_url: nil,
                log: false, log_level: :debug,
                app_id: Settings.ypb.application_id,
                app_password: Settings.ypb.application_password,
                app_name: Settings.ypb.application_name)

    @client =  Savon.client wsdl: wsdl, log: log, log_level: log_level,
                            namespace: nil,
                            env_namespace: :soapenv,
                            namespace_identifier: nil,
                            convert_request_keys_to: :none

    @application_id = app_id
    @application_password = app_password
    @application_name = app_name

    @success_url = success_url
    @failure_url = failure_url
  end

  def get_ack(token_id)
    r = @client.call :acknowledge_complete_status, message: { tokenid: token_id}
  end

  def get_token(payment_transaction)

    response = @client.call ORDER_INITIALIZE_OP


    token_message = setup_required_information response.body, total: payment_transaction.amount
    token_message = setup_order_details token_message, payment_transaction
    token_message = setup_config_settings token_message

    #pp token_message[:order_initialize_response][:order_initialize_result]

    order = token_message[:order_initialize_response][:order_initialize_result]

    items_response = @client.call ITEMS_INITIALIZE_OP, message: { capacity: payment_transaction.records.size }

    order[:items] = setup_items(items_response, payment_transaction)
    order[:taxes] = ""

    pp order[:items]
    order.deep_transform_keys! { |key| "#{key.to_s.camelize}" }


    token_response = @client.call GET_TOKEN_OP, message: { "order": {}.merge(order) }

    return token_response.body[:get_token_response][:get_token_result]
  end

  private

  def setup_required_information(response, total: 0)
    info = {
        ApplicationId: @application_id, #Settings.ypb.application_id,
        ApplicationPassword: @application_password, #Settings.ypb.application_password,
        ApplicationName: @application_name, #Settings.ypb.application_name,
        TransPaymentType: Settings.ypb.transaction_types.purchase,
        ResponseMethod: "POST",
        Total: total
    }

    response[:order_initialize_response][:order_initialize_result][:required_information] = info
    return response
  end

  def setup_order_details(response, payment_transaction)
    details = {
      OrderId: "#{payment_transaction.order_id}",
      Note: "Fines Payment"
    }
    response[:order_initialize_response][:order_initialize_result][:order_details] = details
    return response
  end

  def setup_config_settings(response)
    settings = {
      :show_addresses=>false,
      :show_order_details=>true,
      :email_receipt=>false,
      :url_success=> @success_url,
      :url_fail=> @failure_url,
      :language=>"enUS"
    }
    response[:order_initialize_response][:order_initialize_result][:config_settings] = settings
    return response
  end

  def setup_items(items_response, payment_transaction)
    items_list = []
    #pp "__+++++_____"
    #pp "LOADING: #{payment_transaction.records.size}"
    payment_transaction.records.each_with_index do |record, index|
      items_list << {
        ItemId: record.id,
        Price: record.amount,
        Quantity: 1,
        ItemCode: "#{record.fee.fee_id}",
        Description: ("#{record.fee.item_title} -- ID: #{record.fee.item_barcode}" rescue "N/A")
      }
    end

    return { ItemInfo: items_list }
  end
end

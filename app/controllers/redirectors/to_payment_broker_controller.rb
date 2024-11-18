class Redirectors::ToPaymentBrokerController < AuthenticatedController
  def show

    @transaction = PaymentTransaction.find params[:transaction_id]

    if @transaction.status == PaymentTransaction::STATUS_NEW

      # lets build the broker, depending on which fees we are processing
      broker = setup_broker @transaction

      TLOG.log_ypb_steps current_user.yorku_id, @transaction.id, "Getting the Token from YPB Payment Broker"
      token_id = broker.get_token @transaction

      TLOG.log_ypb_steps current_user.yorku_id, @transaction.id, "Creating a transaction with YPB Token"

      @transaction.uid = token_id
      @transaction.status =  PaymentTransaction::STATUS_PROCESSING
      @transaction.save

      TLOG.log_ypb_steps current_user.yorku_id, @transaction.id, "Redirecting to YPB Payment Broker"

      ## setup payment broker stuff and send person there
      redirect_to "#{Settings.ypb.payment_page_url}?tokenid=#{token_id}", allow_other_host: true
    else
      TLOG.log_ypb_steps current_user.yorku_id, @transaction.id, "ERROR: TRIED REDIRECTING WITH EXISTING TRANSACTION"
      redirect_to transaction_path @transaction
    end
  end

  def setup_broker(transaction)
    if transaction.records.first.fee.owner_id == Alma::Fee::OWNER_OSGOODE
      TLOG.log_ypb_steps current_user.yorku_id, transaction.id, "Redirecting to YPB Payment Broker FOR OSGOODE ACCOUNT"

      Ypb::Broker.new_broker_instance(ypb_postback_url, true)
    else
      TLOG.log_ypb_steps current_user.yorku_id, transaction.id, "Redirecting to YPB Payment Broker FOR YUL ACCOUNT"

      Ypb::Broker.new_broker_instance(ypb_postback_url, false)
    end
  end

end

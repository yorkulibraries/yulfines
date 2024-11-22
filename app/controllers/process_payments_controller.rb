class ProcessPaymentsController < AuthenticatedController
  def new
    if params[:osgoode]
      @fees = current_user.alma_fees.osgoode_fees
      @which = "Osgoode"
    else
      @fees = current_user.alma_fees.other_fees
      @which = "YUL"
    end

    @records = []
    @fees.each do |fee|
      if ! fee.payment_pending?
        @records << PaymentRecord.new(user: current_user, fee: fee, amount: fee.balance)
      end
    end
  end

  def create
    @records = []

    fees.each do |key|
      fee = Alma::Fee.active.find_by_id key
      if fee
        @records << PaymentRecord.new(user: current_user, fee_id: key.to_i, amount: fee.balance )
      end
    end

    if @records.size > 0
      @transaction = PaymentTransaction.create! status: PaymentTransaction::STATUS_NEW,
                                                yorku_id: current_user.yorku_id,
                                                user_primary_id: current_user.username,
                                                user: current_user

      TLOG.log_transaction_step step: TransactionLog::YPB_START,
                  username: current_user.username, transaction_id: @transaction.id,
                  message: "Created new transaction. Status: #{@transaction.status}"

      total_amount = 0
      library_id = nil
      @records.each do |record|
        record.payment_transaction = @transaction
        total_amount += record.amount
        record.save

        TLOG.log_transaction_step step: TransactionLog::YPB_START,
                    username: current_user.username, transaction_id: @transaction.id,
                    message: "Fee Record: #{record.fee.fee_id} Amount: #{record.amount}"

        library_id = record.fee.owner_id if library_id == nil
      end

      @transaction.update library_id: library_id
      @transaction.update amount: total_amount

      TLOG.log_transaction_step step: TransactionLog::YPB_START,
                  username: current_user.username, transaction_id: @transaction.id,
                  message: "Total Amount: #{total_amount}"

      redirect_to_payment_broker
    else
      redirect_to new_process_payment_path, flash: { error: "Please select an item to pay." }
    end
  end

  private
  def fees
    return [] if params[:records].nil?
    records = params.require(:records).permit!
    records[:payment_record].keys
  end

  def redirect_to_payment_broker
    broker = setup_broker @transaction

    TLOG.log_ypb_steps current_user.username, @transaction.id, "Getting the Token from YPB"
    token_id = broker.get_token @transaction

    TLOG.log_ypb_steps current_user.username, @transaction.id, "Updating transaction: #{@transaction.id} with Token: #{token_id}"
    @transaction.uid = token_id
    @transaction.status = PaymentTransaction::STATUS_PROCESSING
    @transaction.save

    TLOG.log_ypb_steps current_user.username, @transaction.id, "Redirecting to YPB"
    redirect_to "#{Settings.ypb.payment_page_url}?tokenid=#{token_id}", allow_other_host: true
  end

  def setup_broker(transaction)
    postback_url = ypb_postback_url + "?id=#{transaction.id}"
    TLOG.log_ypb_steps current_user.username, transaction.id, "Setting post back URL to: #{postback_url}"
    if transaction.records.first.fee.owner_id == Alma::Fee::OWNER_OSGOODE
      TLOG.log_ypb_steps current_user.username, transaction.id, "Using YPB Account for Osgoode"
      Ypb::Broker.new_broker_instance(postback_url, true)
    else
      TLOG.log_ypb_steps current_user.username, transaction.id, "Using YPB Account for YUL"
      Ypb::Broker.new_broker_instance(postback_url, false)
    end
  end
end

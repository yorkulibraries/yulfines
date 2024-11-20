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
                    message: "Alma Record: #{record.fee.item_barcode rescue 'error'} Amount: #{record.amount}"

        library_id = record.fee.owner_id if library_id == nil
      end

      @transaction.update library_id: library_id
      @transaction.update amount: total_amount

      TLOG.log_transaction_step step: TransactionLog::YPB_START,
                  username: current_user.username, transaction_id: @transaction.id,
                  message: "Total Amount: #{total_amount}"

      redirect_to redirect_to_payment_broker_path(transaction_id: @transaction.id)
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
end

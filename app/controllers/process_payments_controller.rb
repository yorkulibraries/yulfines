class ProcessPaymentsController < AuthenticatedController
  def new
    if params[:osgoode]
      @fees = current_user.alma_fees.osgoode_fees
      @which = "Osgoode"
    else
      @fees = current_user.alma_fees.other_fees
      @which = "York University Libraries"
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

    record_params[:payment_record].keys.each do |key|
      amount = record_params[:payment_record][key]["amount"]
      if ! amount.blank?
        fee = Alma::Fee.active.find_by_id key
        if fee
          @records << PaymentRecord.new(user: current_user, fee_id: key.to_i, amount: fee.balance )
        end
      end
    end


    if @records.size > 0

      @transaction = PaymentTransaction.create! status: PaymentTransaction::STATUS_NEW,
                                                yorku_id: current_user.yorku_id,
                                                user: current_user

      TLOG.log_transaction_step step: TransactionLog::YPB_START,
                  yorku_id: current_user.yorku_id, transaction_id: @transaction.id,
                  message: "Created new transaction. Status: #{@transaction.status}"

      total_amount = 0
      library_id = nil
      @records.each do |record|
        record.payment_transaction = @transaction
        total_amount += record.amount
        record.save

        TLOG.log_transaction_step step: TransactionLog::YPB_START,
                    yorku_id: current_user.yorku_id, transaction_id: @transaction.id,
                    message: "Alma Record: #{record.fee.item_barcode rescue 'error'} Amount: #{record.amount}"

        #TLOG.record current_user.yorku_id, "For record: #{record.fee.item_barcode rescue 'error'}"

        # save library id
        library_id = record.fee.owner_id if library_id == nil
      end

      @transaction.update library_id: library_id
      @transaction.update amount: total_amount


      TLOG.log_transaction_step step: TransactionLog::YPB_START,
                  yorku_id: current_user.yorku_id, transaction_id: @transaction.id,
                  message: "Total Amount: #{total_amount}"

      #TLOG.record current_user.yorku_id, "Total Amount: #{total_amount}"


      redirect_to redirect_to_payment_broker_path(transaction_id: @transaction.id)
    else
      redirect_to new_process_payment_path, notice: "Please provide the amount you would like to pay"
    end
  end


  private
  def record_params
    params.require(:records).permit!
  end
end

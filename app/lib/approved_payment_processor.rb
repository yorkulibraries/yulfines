# This is the main class responsible for processing approved payments
# After YPB approves the transaction, Alma needs to be notified
# This is the class that does this.
# In order to ensure that rogue/stalled processes to mess up data and Alma,
# this class will be using Database specific Table Row Locking (MySQL)
# We are going to lock PaymentTransaction and Alma::Fee
class ApprovedPaymentProcessor
  attr_accessor :fee_processor, :fee_url

  def initialize(fee_processor=nil, url: nil)
    @fee_url = url
    if fee_processor == nil
      @fee_processor = instantiate_fee_processor Alma::FeeProcessor, url
    else
      @fee_processor = instantiate_fee_processor fee_processor, url
    end

  end


  def process_approved_transactions
    approved_transactions = PaymentTransaction.approved

    processed_transactions = 0
    approved_transactions.each do |transaction|
      begin
        if pay_alma_fee(transaction)
          processed_transactions = processed_transactions + 1
        end
      rescue StandardError => e
          TLOG.log_ypb_processor transaction.yorku_id, transaction.id, "Transaction wasn't found #{transaction.id}. If transaction exists, likely locking issue."
      end
    end

    return processed_transactions
  end



  def pay_alma_fee(transaction)
    return if transaction == nil

    processing_successful = false

    ## LOCK UP THIS TRANSACTION
    transaction.with_lock do
      return false if ! transaction.approved?

      TLOG.log_ypb_processor transaction.yorku_id, transaction.id, "Processing Alma Fine Transaction: #{transaction.status} YP_ID: #{transaction.yporderid}"

      transaction.records.each do |record|

        # LOCK UP THIS RECORD AS WELL. DOUBLE LOCKED
        #record.with_lock do

          if process_alma_fee record
            record.mark_paid!
            TLOG.log_alma_pay_fee transaction.yorku_id, record.alma_fee_id, transaction.id, "Transaction For Record Paid: #{record.fee.item_barcode rescue 'error'} Fine ID: #{record.alma_fee_id}"
          else
            record.mark_rejected! error_code: @fee_processor.error_code,
                                  error_message: @fee_processor.error_message,
                                  tracking_id: @fee_processor.tracking_id
            TLOG.log_alma_pay_fee transaction.yorku_id, record.alma_fee_id, transaction.id, "Error: #{@fee_processor.error_code} - #{@fee_processor.error_message}"
            #  TLOG.log_ypb_processor transaction.yorku_id, transaction.id, "Transaction For Record Rejected: #{record.fee.item_barcode rescue 'error'}"
          end
        #end # END RECORD LOCK

      end

      transaction.mark_paid!

      processing_successful = true
    end # END LOCK

    return processing_successful
  end


  private

  # Process Alma Fee by using the defined FeeProcessor
  def process_alma_fee(record)
    val = @fee_processor.pay_fee! record
    return val
  end

  def instantiate_fee_processor(class_instance, url)
    if url != nil
      return class_instance.new url: url
    else
      return class_instance.new
    end
  end


end

class TransactionLogger
  def initialize(logfile)
    @logger = TransactionFileLogger.new(logfile)
  end

  def info(msg)
    @logger.info msg
  end

  def record(id, message, logged_at = Time.now)
    LogJob.peform_later message: message, yorku_id: id, logged_at: logged_at
    @logger.record(id, message)
  end

  def log_ypb_processor(yorku_id, transaction_id, message)
    log_transaction_step step: TransactionLog::YPB_PROCESSOR_UPDATE, message: message,
                         yorku_id: yorku_id, transaction_id: transaction_id
  end

  def log_ypb_postback(yorku_id, transaction_id, message)
    log_transaction_step step: TransactionLog::YPB_POSTBACK, message: message,
                         yorku_id: yorku_id, transaction_id: transaction_id
  end

  def log_ypb_steps(yorku_id, transaction_id, message)
    log_transaction_step step: TransactionLog::YPB_PROCESSING, message: message,
                         yorku_id: yorku_id, transaction_id: transaction_id
  end

  def log_transaction_step(yorku_id:, step:, message:, transaction_id:, alma_fee_id: nil)
    LogJob.perform_later message: message, logged_at: Time.now,
                        process_name: step, transaction_id: transaction_id,
                        yorku_id: yorku_id, alma_fee_id: alma_fee_id

    opts = { process_name: step, alma_fee_id: alma_fee_id, transaction_id: transaction_id }
    @logger.record(yorku_id, message, opts)
  end

  def log_alma_pay_fee(yorku_id, alma_fee_id, transaction_id, message)

    LogJob.perform_later message: message, logged_at: Time.now,
                        process_name: TransactionLog::ALMA_PAY_FEE,
                        alma_fee_id: alma_fee_id,
                        yorku_id: yorku_id, transaction_id: transaction_id

    opts = { alma_fee_id: alma_fee_id, transaction_id: transaction_id }
    @logger.record(yorku_id, message, opts)
  end

  def log_load_fees(yorku_id:, logged_at: Time.now, message: nil)
    message = "Loading fees from Alma" if message == nil

    LogJob.perform_later message: message,
                 logged_at: logged_at,
                 process_name: TransactionLog::ALMA_LOAD_FEES,
                 yorku_id: yorku_id

    @logger.record yorku_id, message
  end
end

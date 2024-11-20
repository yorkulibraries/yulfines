class TransactionLogger
  def initialize(logfile)
    @logger = TransactionFileLogger.new(logfile)
  end

  def info(msg)
    @logger.info msg
  end

  def record(username, message, logged_at = Time.now)
    LogJob.peform_later message: message, username: username, logged_at: logged_at
    @logger.record(id, message)
  end

  def log_ypb_processor(username, transaction_id, message)
    log_transaction_step step: TransactionLog::YPB_PROCESSOR_UPDATE, message: message,
                         username: username, transaction_id: transaction_id
  end

  def log_ypb_postback(username, transaction_id, message)
    log_transaction_step step: TransactionLog::YPB_POSTBACK, message: message,
                         username: username, transaction_id: transaction_id
  end

  def log_ypb_steps(username, transaction_id, message)
    log_transaction_step step: TransactionLog::YPB_PROCESSING, message: message,
                         username: username, transaction_id: transaction_id
  end

  def log_transaction_step(username:, step:, message:, transaction_id:, alma_fee_id: nil)
    LogJob.perform_later message: message, logged_at: Time.now,
                        process_name: step, transaction_id: transaction_id,
                        username: username, alma_fee_id: alma_fee_id

    opts = { process_name: step, alma_fee_id: alma_fee_id, transaction_id: transaction_id }
    @logger.record(username, message, opts)
  end

  def log_alma_pay_fee(username, alma_fee_id, transaction_id, message)

    LogJob.perform_later message: message, logged_at: Time.now,
                        process_name: TransactionLog::ALMA_PAY_FEE,
                        alma_fee_id: alma_fee_id,
                        username: username, transaction_id: transaction_id

    opts = { alma_fee_id: alma_fee_id, transaction_id: transaction_id }
    @logger.record(username, message, opts)
  end

  def log_load_fees(username:, logged_at: Time.now, message: nil)
    message = "Loading fees from Alma" if message == nil

    LogJob.perform_later message: message,
                 logged_at: logged_at,
                 process_name: TransactionLog::ALMA_LOAD_FEES,
                 username: username

    @logger.record username, message
  end
end

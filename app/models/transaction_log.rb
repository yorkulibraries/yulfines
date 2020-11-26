class TransactionLog < ApplicationRecord

  ## CONSTANTS ##
  ALMA_LOAD_FEES = "alma_load_fees"
  ALMA_PAY_FEE = "alma_pay_fee"
  YPB_START = "ypb_transaction_start"
  YPB_PROCESSING = "ypb_processing"
  YPB_POSTBACK = "ypb_postback"
  YPB_PROCESSOR_UPDATE = "ypb_processor_update"
  PROCESS_OTHER = "other_process"

  ## RELATIONS ##
  belongs_to :payment_transaction, foreign_key: "transaction_id" , optional: true

  ## VALIDATIONS ##
  validates_presence_of :yorku_id, :logged_at, :message

  ## CALLBACKS ##
  after_create do
    self[:process_name] = PROCESS_OTHER if self[:process_name].blank?
  end

  ## HELPER TO CREAT A LOG QUICKLY
  def TransactionLog.log(opts = {})
    tlog = TransactionLog.new
    tlog.yorku_id = opts[:yorku_id]
    tlog.logged_at = opts[:logged_at]
    tlog.message = opts[:message]
    tlog.transaction_id = opts[:transaction_id]
    tlog.ypb_transaction_id = opts[:ypb_transaction_id]
    tlog.process_name = opts[:process_name]
    tlog.alma_fee_id = opts[:alma_fee_id]
    tlog.additional_changes = opts[:additional_changes]

    tlog.save
  end

end

class LogJob < ApplicationJob
  queue_as :logging


  def perform(opts = {})
    ## Record transaction log
    TransactionLog.log message: opts[:message],
                       yorku_id: opts[:yorku_id],
                       alma_fee_id: opts[:alma_fee_id],
                       logged_at: opts[:logged_at],
                       transaction_id: opts[:transaction_id],
                       ypb_transaction_id: opts[:ypb_transaction_id],
                       process_name: opts[:process_name],
                       additional_changes: opts[:additional_changes]
  end
end

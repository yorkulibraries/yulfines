## RUN rake ypb:check_receipts and rake ypb:clean_up_incomplete_transactions
## THEN rake alma:pay_fines
namespace :ypb do
  task check_receipts: :environment do
    cron_lock "checking_receipts" do
      processing_transactions = PaymentTransaction.processing.older_than
      TLOG.info "Processing #{processing_transactions.size} transaction"

      processing_transactions.each do |txn|
        parser = Ypb::ReceiptParser.new

        TLOG.log_ypb_processor txn.yorku_id, txn.id, "Beginning To Process: #{txn.status} YP_ID: #{txn.yporderid}"

        url  = "#{Settings.ypb.receipt_page_url}?tokenid=#{txn.uid}"
        response = HTTParty.get(url)

        if response.code.to_s == "200"

          receipt = parser.parse_receipt response.body
          txn = parser.copy_receipt_to_transaction receipt, txn

          txn.save

          TLOG.log_ypb_processor txn.yorku_id, txn.id, "Processing Transaction: #{txn.status} YP_ID: #{txn.yporderid}"

          if txn.declined? || txn.cancelled?
            TLOG.log_ypb_processor txn.yorku_id, txn.id, "Transaction declined/cancelled: #{txn.status} YP_ID: #{txn.yporderid}"
            txn.records.each do |record|
              record.mark_incomplete!
            end
          end
          TLOG.log_ypb_processor txn.yorku_id, txn.id, "Finished Processing Transaction: #{txn.status} YP_ID: #{txn.yporderid}"
        end
      end

      ## CLEAN UP TRANSACTIONS THAT HAVE BEEN DECLINED OR CANCELLED
      Rake::Task["ypb:clean_up_incomplete_transactions"].invoke

    end # end of cron lock
  end

  task  clean_up_incomplete_transactions: :environment do
    transactions = PaymentTransaction.declined_or_cancelled
    TLOG.info "Cleaning up incomplete transactions - #{transactions.size}"

    transactions.each do |txn|
      if txn.declined? || txn.cancelled?
        txn.records.each do |record|
          record.mark_incomplete!
        end
        #TLOG.log_ypb_processor txn.yorku_id, txt.id, "Cleaned Up: #{txn.status} ID: #{txn.id}"
      end
    end

  end


  def cron_lock(name)
    #pp "CHECKING IF LOCK EXISTS"
    path = Rails.root.join('tmp', 'cron', "#{name}.lock")
    mkdir_p path.dirname unless path.dirname.directory?
    file = path.open('w')
    if file.flock(File::LOCK_EX | File::LOCK_NB) == false
      #pp "LOCKED"
      return
    else
      #pp "NOT LOCKED"
      yield
    end
  end
end

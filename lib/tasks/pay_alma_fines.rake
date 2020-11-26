namespace :alma do

  task pay_fines: :environment do
    cron_lock "alma_fees_processing" do
      processor = ApprovedPaymentProcessor.new # Make sure to use this
      processed_transactions = processor.process_approved_transactions

      TLOG.info "Processed #{processed_transactions} approved transactions"
    end
  end

  def cron_lock(name)

    path = Rails.root.join('tmp', 'cron', "#{name}.lock")
    mkdir_p path.dirname unless path.dirname.directory?
    file = path.open('w')
    if file.flock(File::LOCK_EX | File::LOCK_NB) == false
      return
    else
      yield
    end
  end
end

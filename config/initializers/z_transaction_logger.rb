logfile = File.open("#{Rails.root}/log/transactions.log", 'a')  # create log file
logfile.sync = true  # automatically flushes data to file
TLOG = TransactionLogger.new(logfile)  # constant accessible anywhere

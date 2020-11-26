class TransactionFileLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{severity} #{process_message msg}\n"
  end

  def process_message(msg)
    case msg
    when ::Array
      msg.join( " --- ")
    when ::String
      msg
    when ::Exception
      "#{ msg.message } (#{ msg.class })\n" <<
        (msg.backtrace || []).join("\n")
    else
      msg.inspect
    end
  end

  def record(id, message, opts = { })
    list = opts.map { |k, v| "#{k}:#{v}" }.join(" | ")
    m = opts.empty? ? message : "#{message} (#{list})"
    s = "[UID: #{id}] -- #{m}"
    info(s)
  end
end

class ReportsController < AdminController

  def index
    @library = report_params[:library]
    @status = report_params[:status]
    @from = report_params[:from]
    @to = report_params[:to]

    @transactions = transactios_with_status @status

    @from_date = @from.blank? ? 1.month.ago : Date.parse(@from)
    @to_date = @to.blank? ? Date.today : Date.parse(@to)

    @transactions = @transactions.where('created_at BETWEEN ? AND ?', @from_date.beginning_of_day, @to_date.end_of_day)

    if !@library.blank?
      if @library == Alma::Fee::OWNER_OSGOODE
        @transactions = @transactions.where("library_id = ?" , Alma::Fee::OWNER_OSGOODE)
      elsif @library == "yorku"
        @transactions = @transactions.where.not("library_id = ?" , Alma::Fee::OWNER_OSGOODE)
      end
    end

    @grouped_transactions = @transactions.group_by(&:status)
  end

  private

  def report_params
    if params[:report] != nil
      params.require(:report).permit(:library, :status, :from, :to)
    else
      Hash.new
    end
  end

  def transactios_with_status(status)
    case status
    when PaymentTransaction::STATUS_PROCESSING
      PaymentTransaction.processing
    when PaymentTransaction::STATUS_PAID
      PaymentTransaction.paid
    when PaymentTransaction::STATUS_PAID_PARTIAL
      PaymentTransaction.paid_partial
    when PaymentTransaction::STATUS_REJECTED_BY_ALMA
      PaymentTransaction.rejected_by_alma
    when PaymentTransaction::STATUS_APPROVED
      PaymentTransaction.approved
    when PaymentTransaction::STATUS_DECLINED
      PaymentTransaction.declined
    when PaymentTransaction::STATUS_CANCELLED
      PaymentTransaction.cancelled
    else
      PaymentTransaction.all
    end
  end
end

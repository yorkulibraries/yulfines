class Reports::TransactionLogsController < AdminController

  def show
    @transaction = PaymentTransaction.find(params[:id])
    @logs = TransactionLog.where(transaction_id: params[:id]).order(:logged_at)
  end
end

class Reports::TransactionsController < AdminController
  def show
    @transaction = PaymentTransaction.find(params[:id])
    @logs = TransactionLog.where(transaction_id: @transaction.id).order(:logged_at)
  end
end

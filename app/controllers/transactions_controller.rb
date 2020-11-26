class TransactionsController < AuthenticatedController
  
  def index
    @approved_transactions = current_user.payment_transactions.approved
    @paid_transactions = current_user.payment_transactions.paid
    @declined_transactions = current_user.payment_transactions.declined
    @cancelled_transactions = current_user.payment_transactions.cancelled
    @processing_transactions = current_user.payment_transactions.processing

    #@transactions = current_user.payment_transactions
    @total_transactions = @approved_transactions.size
    @total_transactions += @paid_transactions.size
    @total_transactions += @declined_transactions.size
    @total_transactions += @cancelled_transactions.size
    @total_transactions += @processing_transactions.size
  end

  def show
    @transaction = current_user.payment_transactions.find(params[:id])
  end
end

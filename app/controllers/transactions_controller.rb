class TransactionsController < AuthenticatedController
  
  def index
    @approved_transactions = current_user.payment_transactions.approved.order('created_at DESC')
    @paid_transactions = current_user.payment_transactions.paid.order('created_at DESC')
    @declined_transactions = current_user.payment_transactions.declined.order('created_at DESC')
    @cancelled_transactions = current_user.payment_transactions.cancelled.order('created_at DESC')
    @processing_transactions = current_user.payment_transactions.processing.order('created_at DESC')

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

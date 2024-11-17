class TransactionsController < AuthenticatedController
  
  def index
    @transactions = current_user.payment_transactions.order('created_at DESC')
    @total_transactions = @transactions.size
  end

  def show
    @transaction = current_user.payment_transactions.find(params[:id])
  end
end

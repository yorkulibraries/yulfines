class Reports::TransactionsController < AdminController
  def show
    @transaction = PaymentTransaction.find(params[:id])
  end
end

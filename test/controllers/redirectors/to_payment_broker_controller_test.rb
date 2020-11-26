require 'test_helper'

class Redirectors::ToPaymentBrokerControllerTest < ActionDispatch::IntegrationTest

  logged_in_with_user do

    should "redirect to transaction details path if status is not new" do
      transaction = create :payment_transaction, status: PaymentTransaction::STATUS_APPROVED, amount: 10
      
      get redirect_to_payment_broker_path(transaction_id: transaction.id)
      assert_response :redirect
      assert_redirected_to transaction_path(transaction)
    end

    should "redirect to payment broker" do
      transaction = create :payment_transaction, status: PaymentTransaction::STATUS_NEW, amount: 10
      record = create :payment_record, payment_transaction: transaction, user: transaction.user, amount: 8.00
      record2 = create :payment_record, payment_transaction: transaction, user: transaction.user, amount: 2.00


      get redirect_to_payment_broker_path(transaction_id: transaction.id)

      transaction.reload
      token_id = transaction.uid

      assert_not_nil token_id
      assert_equal  PaymentTransaction::STATUS_PROCESSING, transaction.status
      assert_response :redirect
      assert_equal "#{Settings.ypb.payment_page_url}?tokenid=#{token_id}", @response.redirect_url
    end

  end

end

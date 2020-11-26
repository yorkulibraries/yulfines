require 'test_helper'

class ProcessPaymentsControllerTest < ActionDispatch::IntegrationTest


  logged_in_with_user do

    should "show a list of fees to be paid by the user" do
      fee = create :alma_fee, yorku_id: @user.yorku_id
      get new_process_payment_path
      assert_response :ok

      assert_match fee.item_title, response.body
    end

    should "create the list of payment records and redirect to payment broker redirector" do
      fee1 = create :alma_fee, yorku_id: @user.yorku_id, balance: 3
      fee2 = create :alma_fee, yorku_id: @user.yorku_id, balance: 7

      records = {
        payment_record: {
                          fee1.id => { "amount" => fee1.balance },
                          fee2.id => { "amount" => fee2.balance }
                        }
      }

      assert_difference "PaymentRecord.count", 2 do
        assert_difference "PaymentTransaction.count" do
          post process_payments_path params: { records: records }
          assert_response :redirect

          records = PaymentRecord.all.order(id: :desc).limit 2
          transaction = PaymentTransaction.last

          assert_equal transaction.yorku_id, @user.yorku_id
          assert_equal transaction.user_id, @user.id
          assert_equal transaction.status, PaymentTransaction::STATUS_NEW
          assert_equal transaction.amount, records.map(&:amount).reduce(0, :+)
          assert_equal transaction.library_id, records.last.fee.owner_id
          
          assert_equal records.first.transaction_id, transaction.id
          assert_equal records.last.transaction_id, transaction.id

          assert_equal records.first.yorku_id, @user.yorku_id
          assert_equal records.last.yorku_id, @user.yorku_id

          assert_equal records.find_by_fee_id(fee1.id).amount, fee1.balance
          assert_equal records.find_by_fee_id(fee2.id).amount, fee2.balance

          assert_equal records.find_by_fee_id(fee2.id).alma_fee_id, fee2.fee_id
          assert_equal records.find_by_fee_id(fee1.id).alma_fee_id, fee1.fee_id

          assert_redirected_to redirect_to_payment_broker_path(transaction_id: transaction.id)
        end
      end

    end
  end
end

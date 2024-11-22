require 'test_helper'

class ProcessPaymentsControllerTest < ActionDispatch::IntegrationTest
  logged_in_with_user do
    should "show a list of fees to be paid by the user" do
      fee = create :alma_fee, user_primary_id: @user.username
      get new_process_payment_path
      assert_response :ok
      assert_match fee.item_title, response.body
    end

    should "create the list of payment records and redirect to payment broker redirector" do
      fee1 = create :alma_fee, user_primary_id: @user.username, balance: 3
      fee2 = create :alma_fee, user_primary_id: @user.username, balance: 7

      records = {
        payment_record: {
          fee1.id => { "amount" => fee1.balance },
          fee2.id => { "amount" => fee2.balance }
        }
      }

      payment_records_count_before = PaymentRecord.count
      payment_transactions_count_before = PaymentTransaction.count

      VCR.use_cassette('new_payment_transaction') do
        post process_payments_path params: { records: records }
        assert_response :redirect

        payment_transactions_count_after = PaymentTransaction.count
        assert_equal payment_transactions_count_after, payment_transactions_count_before + 1

        transaction = PaymentTransaction.last

        assert_redirected_to "#{Settings.ypb.payment_page_url}?tokenid=#{transaction.uid}"

        payment_records_count_after = PaymentRecord.count
        assert_equal payment_records_count_after, payment_records_count_before + 2

        records = PaymentRecord.all.order(id: :desc).limit 2

        assert_equal transaction.yorku_id, @user.yorku_id
        assert_equal transaction.user_id, @user.id
        assert_equal transaction.status, PaymentTransaction::STATUS_PROCESSING
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
      end
    end
  end
end

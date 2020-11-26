class YpbPostbackController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    # only used to display an error page
  end

  def create
    token_id = params[:tokenid]
    order_id = params[:orderid]

    transaction = PaymentTransaction.processing.where(uid: token_id, order_id: order_id).first

    if transaction
      transaction.yporderid = params[:yporderid]
      transaction.status = params[:status]
      transaction.message = params[:message]
      transaction.cardtype = params[:cardtype]
      transaction.authcode = params[:authcode]
      transaction.refnum = params[:refnum]
      transaction.txn_num = params[:txn_num]
      transaction.cardholder = params[:cardholder]
      transaction.cardnum = params[:cardnum]

      if transaction.status == PaymentTransaction::STATUS_APPROVED
        transaction.ypb_transaction_approved_at = Date.current
      elsif transaction.status == PaymentTransaction::STATUS_DECLINED
        transaction.ypb_transaction_declined_at = Date.current
      end

      transaction.save

      TLOG.log_ypb_postback transaction.yorku_id, transaction.id,  "Post Back From YPB"
      TLOG.log_ypb_postback transaction.yorku_id, transaction.id, "Transaction: #{transaction.status} YP_ID: #{transaction.yporderid}"

      if transaction.declined? || transaction.cancelled?
        transaction.records.each do |record|
          record.mark_incomplete!
        end
      end

      redirect_to transaction_path(transaction)
    else
      render action: :show
    end


  end
end

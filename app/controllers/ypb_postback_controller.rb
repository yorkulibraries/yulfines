class YpbPostbackController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    # only used to display an error page
  end

  def create
    token_id = params[:tokenid]
    order_id = params[:orderid]
    status = params[:status]
    ypborderid = params[:ypborderid]

    @transaction = PaymentTransaction.processing.where(uid: token_id, order_id: order_id).first
    if @transaction
      TLOG.log_ypb_postback @transaction.user_primary_id, @transaction.id,  "Post Back From YPB - status: #{status}, ypborderid: #{ypborderid} "
      TLOG.log_ypb_postback @transaction.user_primary_id, @transaction.id,  "Begin parsing receipt for transaction status"
      
      if parse_receipt
        TLOG.log_ypb_postback @transaction.user_primary_id, @transaction.id, "Parsed receipt OK"

        if @transaction.status == PaymentTransaction::STATUS_APPROVED
          @transaction.ypb_transaction_approved_at = Date.current
        elsif @transaction.status == PaymentTransaction::STATUS_DECLINED
          @transaction.ypb_transaction_declined_at = Date.current
        end

        @transaction.save

        TLOG.log_ypb_postback @transaction.user_primary_id, @transaction.id, "status: #{@transaction.status} ypborderid: #{@transaction.yporderid}"

        if @transaction.declined? || @transaction.cancelled?
          @transaction.records.each do |record|
            record.mark_incomplete!
          end
        end
      else
        TLOG.log_ypb_postback @transaction.user_primary_id, @transaction.id, "Failed to parse receipt."
      end
      redirect_to transaction_path(@transaction)
    else
      render action: :show
    end
  end

  private
  def parse_receipt
    parser = Ypb::ReceiptParser.new
    url  = "#{Settings.ypb.receipt_page_url}?tokenid=#{@transaction.uid}"
    response = HTTParty.get(url)
    
    if response.code.to_s == "200"
      receipt = parser.parse_receipt response.body
      Rails.logger.debug receipt
      if PaymentTransaction::STATUSES.include?(receipt[:status])
        parser.copy_receipt_to_transaction receipt, @transaction
        return true
      end
    end
    return false
  end
end

class AddFieldsToTransactionAndRecord < ActiveRecord::Migration[6.0]
  def change
    add_column :payment_transactions, :yporderid, :string
    add_column :payment_transactions, :alma_fines_paid_at, :datetime
    add_column :payment_transactions, :ypb_transaction_approved_at, :datetime
    add_column :payment_transactions, :ypb_transaction_declined_at, :datetime

    add_column :payment_records, :alma_fines_paid_at, :datetime
    add_column :payment_records, :alma_fines_rejected_at, :datetime
    add_column :payment_records, :alma_fines_rejected_error_reason, :string
    add_column :payment_records, :alma_fines_rejected_error_code, :string
    add_column :payment_records, :alma_fines_rejected_error_tracking_id, :string
  end
end

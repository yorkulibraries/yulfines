class AddAlamFeeItemFieldsToPaymentRecord < ActiveRecord::Migration[6.0]
  def change
    add_column :payment_records, :fee_owner_id, :string
    add_column :payment_records, :fee_owner_description, :string
    add_column :payment_records, :fee_item_title, :string
    add_column :payment_records, :fee_item_barcode, :string
  end
end

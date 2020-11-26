class ChangeTitleToText < ActiveRecord::Migration[6.0]
  def change
    change_column :alma_fees, :item_title, :text
    change_column :payment_records, :fee_item_title, :text
    change_column :payment_records, :payment_token, :text

    change_column :transaction_logs, :message, :text

  end
end

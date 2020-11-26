class CreatePaymentTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_transactions do |t|
      t.string :uid
      t.integer :user_id
      t.string :yorku_id
      t.string :status
      t.string :order_id
      t.string :message
      t.string :cardtype
      t.float :amount
      t.string :authcode
      t.string :refnum
      t.string :txn_num
      t.string :cardholder
      t.string :cardnum
      t.timestamps
    end
  end
end

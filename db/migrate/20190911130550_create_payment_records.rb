class CreatePaymentRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_records do |t|
      t.integer :fee_id
      t.integer :user_id
      t.integer :transaction_id
      t.string :yorku_id
      t.string :alma_fee_id
      t.float :amount
      t.string :status
      t.string :payment_token

      t.timestamps
    end
  end
end

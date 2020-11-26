class CreateTransactionLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :transaction_logs do |t|
      t.string :yorku_id
      t.string :alma_fee_id
      t.integer :transaction_id
      t.string :ypb_transaction_id
      t.datetime :logged_at
      t.string :process_name
      t.string :message
      t.text :additional_changes

      t.timestamps
    end

    add_index :transaction_logs, :yorku_id
    add_index :transaction_logs, :transaction_id    
  end
end

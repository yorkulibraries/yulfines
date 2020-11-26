class AddLibraryIdToPaymentTransaction < ActiveRecord::Migration[6.0]
  def change
    add_column :payment_transactions, :library_id, :string
  end
end

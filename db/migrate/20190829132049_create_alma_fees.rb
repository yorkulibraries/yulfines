class CreateAlmaFees < ActiveRecord::Migration[6.0]
  def change
    create_table :alma_fees do |t|
      t.string :fee_id
      t.string :fee_type
      t.string :fee_description
      t.string :fee_status
      t.string :user_primary_id
      t.float :balance
      t.float :remaining_vat_amount
      t.float :original_amount
      t.float :original_vat_amount
      t.datetime :creation_time
      t.datetime :status_time
      t.string :owner_id
      t.string :owner_description
      t.string :item_title
      t.string :item_barcode
      t.string :yorku_id

      t.timestamps
    end

    add_index :alma_fees, :fee_id, unique: true
    add_index :alma_fees, [:fee_id, :yorku_id]
  end
end

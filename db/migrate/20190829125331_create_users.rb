class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password
      t.string :role
      t.string :level
      t.string :yorku_id

      t.timestamps
    end

    add_index :users, :yorku_id, unique: true
  end
end

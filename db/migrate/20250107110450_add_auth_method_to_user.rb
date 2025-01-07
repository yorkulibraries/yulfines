class AddAuthMethodToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :auth_method, :string
  end
end

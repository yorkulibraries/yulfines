class AddAdminFlagToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :became_admin_at, :datetime, default: nil
  end
end

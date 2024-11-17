class RemoveRememberableFromUsers < ActiveRecord::Migration[7.0]
  def self.up
    remove_column :users, :remember_created_at
  end
  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
end

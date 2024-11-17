class AddLockableToUsers < ActiveRecord::Migration[7.0]
  def self.up
    change_table :users do |t|
      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      #t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at
    end
  end
  def self.down
    remove_column :users, :failed_attempts
    #remove_column :users, :unlock_token
    remove_column :users, :locked_at
  end
end

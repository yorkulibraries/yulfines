namespace :yul_fines do
  task fix_libray_id_in_transaction: :environment do
    transactions = PaymentTransaction.all

    transactions.each do |t|
      begin
        library_id = t.records.last.fee.owner_id
        t.update library_id: library_id
      rescue
      end
    end
  end

  #  rake yul_fines:grant_admin_access USER_ID=yorku_id from alma
  # RAILS_ENV=production bundle exec  rake yul_fines:grant_admin_access USER_ID=
  task grant_admin_access: :environment do
    user = User.find_by_yorku_id ENV["USER_ID"].to_i
    user.make_admin!
  end

  # rake yul_fines:revoke_admin_access USER_ID=yorku_id from alma
  # RAILS_ENV=production bundle exec  rake yul_fines:revoke_admin_access USER_ID=
  task revoke_admin_access: :environment do
    user = User.find_by_yorku_id ENV["USER_ID"].to_i
    user.revoke_admin!
  end
end

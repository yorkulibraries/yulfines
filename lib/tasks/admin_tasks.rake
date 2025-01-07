namespace :yulfines do

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

  task invalid_user_records: :environment do
    User.all.each do |u|
      if !u.valid?
        puts "#{u.username},#{u.yorku_id},#{u.email},#{u.id}"
      end
    end
  end

  task count: :environment do
    puts "#{User.count} User"
    puts "#{Alma::Fee.count} Alma::Fee"
    puts "#{PaymentTransaction.count} PaymentTransaction"
    puts "#{PaymentRecord.count} PaymentRecord"
    puts "#{TransactionLog.count} TransactionLog"
  end

  task admins: :environment do
    User.all.each do |u|
      if u.admin?
        puts "#{u.username},#{u.yorku_id},#{u.email},#{u.id}"
      end
    end
  end
end

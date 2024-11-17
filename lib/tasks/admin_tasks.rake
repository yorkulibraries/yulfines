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

  task fix_old_user_records: :environment do
    # fix known duplicate users
    u = User.find 2080
    u2 = User.find 2
    u13 = User.find 13
    u2.payment_transactions.each do |t|
      t.user = u
      t.save
    end
    u13.payment_transactions.each do |t|
      t.user = u
      t.save
    end

    u = User.find 3759
    u3063 = User.find 3063
    u3063.payment_transactions.each do |t|
      t.user = u
      t.save
    end

    # if a user record has no payment transaction then simply delete it
    User.all.each do |u|
      if u.payment_transactions.empty?
        u.destroy
      end
    end

    User.where("length(email)>0").all.each do |u|
      email = u.email.gsub('@@', '@').delete('["').delete('"]')
      email = email.split(',').first
      u.email = email
      u.save(validate: false)
    end

    # these records get created when login with barcode and the Alma record does not have UNIV_ID
    # so the barcode got saved to the yorku_id (wrongly), yorku_id should be nil in these instances
    puts "FIX CASE: wrong use of yorku_id -  username = yorku_id and yorku_id like '290070%'"
    User.where("username = yorku_id and yorku_id like '290070%'").each do |u|
      u.yorku_id = nil

      if u.save
        puts "#{u.username},#{u.yorku_id},#{u.email},#{u.id}"
      end
    end

    # these records get created when login PYORK but the yorku_id is (wrongly) saved to the username field
    # in addition to the yorku_id field => invalidate the username field
    puts "FIX CASE: wrong use of username -  length(username) = 9 and username = yorku_id "
    User.where("username = yorku_id and length(username) = 9").each do |u|
      u.username = 'CYIN' + u.username

      if u.save
        puts "#{u.username},#{u.yorku_id},#{u.email},#{u.id}"
      end
    end

    # flip back the sername/yorku_id if possible
    puts "FIX CASE: flipped yorku_id and username - yorku_id like '290070%' and length(username) = 9"
    User.where("yorku_id like '290070%' and length(username) = 9").each do |u|
      if u.username.length == 9
        username = u.username
        yorku_id = u.yorku_id
        u.yorku_id = username
        u.username = yorku_id

        if u.save
          puts "#{u.username},#{u.yorku_id},#{u.email},#{u.id}"
        end
      end
    end
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
    puts "#{PaymentTransaction.count} PaymentTransaction"
    puts "#{PaymentRecord.count} PaymentRecord"
    puts "#{TransactionLog.count} TransactionLog"
  end

end

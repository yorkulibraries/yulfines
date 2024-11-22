FactoryBot.define do
  factory :payment_record do
    association :user
    fee { association :alma_fee, user_primary_id: user.username rescue nil }
    payment_transaction { association :payment_transaction, user_primary_id: user.username, user: user rescue nil }
    amount { fee.balance rescue 0}
    yorku_id { user.yorku_id rescue nil }
    user_primary_id { user.username rescue nil }
    alma_fee_id { fee.fee_id rescue nil }
    status { PaymentRecord::STATUS_PAID }
    payment_token { SecureRandom.hex(8) }
  end
end

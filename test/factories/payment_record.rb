FactoryBot.define do

  factory :payment_record do
    association :user
    fee { association :alma_fee, yorku_id: user.yorku_id rescue nil }
    payment_transaction { association :payment_transaction, yorku_id: user.yorku_id, user: user rescue nil }

    amount { fee.balance rescue 0}
    yorku_id { user.yorku_id rescue nil }
    alma_fee_id { fee.fee_id rescue nil }

    status { PaymentRecord::STATUS_PAID }
    payment_token { SecureRandom.hex(8) }
  end
end

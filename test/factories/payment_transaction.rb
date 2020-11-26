FactoryBot.define do

  factory :payment_transaction do
    association :user
    yorku_id { user.yorku_id rescue nil }

    status { PaymentTransaction::STATUS_NEW  }
    order_id { nil }
    message { nil }
    cardtype { nil }
    amount { 0.0 }
    authcode { nil }
    refnum { nil }
    txn_num { nil }
    cardholder { nil }
    cardnum { nil }
  end
end

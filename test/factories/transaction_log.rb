FactoryBot.define do

  factory :transaction_log do
    sequence(:yorku_id)  { |n| "#{n}#{n}12393939" }
    alma_fee_id { nil }
    transaction_id { nil }
    ypb_transaction_id { nil }
    logged_at { 2.days.ago }
    process_name { TransactionLog::ALMA_LOAD_FEES }
    message { "Loaded fees for user"}
    additional_changes { nil  }
  end
end

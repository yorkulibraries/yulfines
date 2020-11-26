FactoryBot.define do

  factory :alma_fee,  class: "Alma::Fee" do
    sequence(:fee_id)  { |n| "#{n}#{n}1223223" }
    fee_type { "OVERDUE" }
    fee_description { "Overdue fine"}
    fee_status { "ACTIVE" }
    sequence(:user_primary_id)  { |n| "#{n}#{n}12393939" }
    balance { 4.25 }
    remaining_vat_amount { 0.0 }
    original_amount { 4.25 }
    original_vat_amount { 0.0 }

    creation_time { 3.years.ago}
    status_time { 1.week.ago }
    owner_id { "SCOTT" }
    owner_description { "Scott Library" }

    sequence(:item_title)  { |n| "Some Cool Book with #{n} NUMBER" }
    sequence(:item_barcode)  { |n| "#{n}#{n}99938838383838" }

    sequence(:yorku_id)  { |n| "#{n}#{n}1239" }    
  end
end

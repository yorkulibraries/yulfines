FactoryBot.define do

  factory :user do
    first_name { "John" }
    last_name { "Smith" }
    sequence(:email) { |n| "#{first_name.downcase}_#{last_name.downcase rescue nil}@example#{n}.com" }
    password { SecureRandom.hex(8) }

    sequence(:yorku_id)  { |n| "#{n}#{n}12393939" }


  end
end

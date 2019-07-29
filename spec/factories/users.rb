FactoryBot.define do
  sequence :email do |n|
    "email#{n}@test.com"
  end

  factory :user do
    email
    password { "12345678" }
    password_confirmation { "12345678" }
    confirmed_at { Time.now }

    trait :unconfirmed_email do
      confirmed_at { nil }
    end
  end
end

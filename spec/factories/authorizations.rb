FactoryBot.define do
  factory :authorization do
    provider { "github" }
    uid { "654321" }

    trait :with_user do
      user
      oauth_email { user.email }
    end
  end
end

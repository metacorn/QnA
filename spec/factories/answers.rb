FactoryBot.define do
  factory :answer do
    body { "#{"b" * 50}" }
    user

    trait :invalid do
      body { "#{"b" * 49}" }
    end
  end
end

FactoryBot.define do
  factory :answer1, :class => Answer do
    body { "#{"b" * 50}" }

    trait :short_body do
      body { "#{"b" * 49}" }
    end
  end
end

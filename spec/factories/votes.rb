FactoryBot.define do
  factory :vote do
    user
    association :votable, factory: :question

    trait :positive do
      value { 1 }
    end

    trait :negative do
      value { -1 }
    end
  end
end

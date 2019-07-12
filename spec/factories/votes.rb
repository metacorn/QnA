FactoryBot.define do
  factory :vote do
    user
    association :votable, factory: :question

    trait :positive do
      kind { :positive }
    end

    trait :negative do
      kind { :negative }
    end
  end
end

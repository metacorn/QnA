FactoryBot.define do
  factory :link do
    name { "MyString" }
    association :linkable, factory: :answer

    trait :valid do
      url { "http://abc.com" }
    end

    trait :invalid do
      url { "qwerty" }
    end
  end
end

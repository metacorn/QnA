FactoryBot.define do
  factory :link do
    name { "MyString" }

    trait :linkable do
      association :linkable, factory: :answer
    end

    trait :valid do
      url { "http://abc.com" }
    end

    trait :invalid do
      url { "qwerty" }
    end

    trait :valid_gist do
      url { "https://gist.github.com/metacorn/99f81dab3792c594fd02eb84ab53f85e" }
    end

    trait :invalid_gist do
      url { "https://gist.github.com/metacorn/1234567890" }
    end
  end
end

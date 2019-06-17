FactoryBot.define do
  sequence :title do |n|
    "Title of the question ##{n}"
  end

  factory :question do
    title { generate :title }
    body { "#{"a" * 50}" }

    trait :invalid do
      title { "Title" }
    end
  end
end

FactoryBot.define do
  factory :question1, :class => Question do
    title { "Title of the first question" }
    body { "#{"a" * 50}" }

    trait :invalid do
      title { "Title" }
    end
  end

  factory :question2, :class => Question do
    title { "Title of the second question" }
    body { "#{"b" * 50}" }

    trait :the_same_title_as_of_the_first_question do
      title { "Title of the first question" }
    end
  end
end

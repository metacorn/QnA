FactoryBot.define do
  factory :question1, :class => Question do
    title { "Title of the first question" }
    body { "#{"a" * 50}" }

    trait :short_title do
      title { "Title" }
    end

    trait :long_title do
      title { "#{"Title" * 20}" }
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

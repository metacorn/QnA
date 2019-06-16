FactoryBot.define do
  factory :question1, :class => Question do
    title { "Title of the first question" }
    body { "#{"a" * 50}" }
  end
  factory :question2, :class => Question do
    title { "Title of the second question" }
    body { "#{"b" * 50}" }
  end
  factory :question3, :class => Question do
    title { "Title of the third question" }
    body { "#{"c" * 50}" }
  end
end

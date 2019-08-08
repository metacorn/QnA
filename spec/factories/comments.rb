FactoryBot.define do
  sequence :body do |n|
    "comment's body ##{n}"
  end

  factory :comment do
    body { generate :body }
    user { nil }
  end
end

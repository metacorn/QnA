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

    trait :with_attachments do
      files { [Rack::Test::UploadedFile.new(Rails.root.join('spec/rails_helper.rb'), 'text/plain')] }
    end
  end
end

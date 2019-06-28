FactoryBot.define do
  factory :answer do
    body { "#{"b" * 50}" }
    question
    user

    trait :invalid do
      body { "#{"b" * 49}" }
    end

    trait :with_attachments do
      files { [Rack::Test::UploadedFile.new(Rails.root.join('spec/rails_helper.rb'), 'text/plain')] }
    end
  end
end

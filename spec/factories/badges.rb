FactoryBot.define do
  factory :badge do
    name { "Badge name" }
    image { Rack::Test::UploadedFile.new(Rails.root.join('tmp/images/badge.png'), 'image/png') }
  end
end

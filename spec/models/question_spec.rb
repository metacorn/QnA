require 'rails_helper'

RSpec.describe Question, type: :model do
  it { should have_many(:answers).dependent(:destroy) }

  it { should validate_presence_of :title }
  it { should validate_presence_of :body }

  it { should validate_length_of(:title).is_at_least(15) }
  it { should validate_length_of(:title).is_at_most(75) }
  it { should validate_length_of(:body).is_at_least(50) }

  it { should validate_uniqueness_of(:title).case_insensitive }
end

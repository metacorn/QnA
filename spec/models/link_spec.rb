require 'rails_helper'

RSpec.describe Link, type: :model do
  it { should belong_to :linkable }

  it { should validate_presence_of :name }
  it { should validate_presence_of :url }

  let(:valid_link) { build(:link, :valid) }
  let(:invalid_link) { build(:link, :invalid) }

  it 'validates valid url format' do
    expect(valid_link).to be_valid
  end

  it 'not validates invalid url format' do
    expect(invalid_link).to be_invalid
  end
end

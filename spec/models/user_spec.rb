require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many :questions }
  it { should have_many :answers }
  it { should have_many(:badges).dependent(:destroy) }

  it { should validate_presence_of :email }
  it { should validate_presence_of :password }

  describe '#owner?' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:question1) { create(:question, user: user1) }
    let(:question2) { create(:question, user: user2) }

    it 'check if user is owner of resource created by himself' do
      expect(user1).to be_owner(question1)
    end

    it 'check if user is not owner of resource created by another user' do
      expect(user1).to_not be_owner(question2)
    end
  end
end

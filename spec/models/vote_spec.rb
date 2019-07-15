require 'rails_helper'

RSpec.describe Vote, type: :model do
  it { should belong_to :votable }
  it { should belong_to :user }
  it { should validate_uniqueness_of(:user).scoped_to(:votable_id).with_message('user has already voted for/against this resource') }

  (1..6).each { |i| let("user#{i}".to_sym) { create(:user) } }
  let(:votable) { create(:question, user: user6) }
  let!(:vote1) { create(:vote, :positive, votable: votable, user: user1) }
  let!(:vote2) { create(:vote, :positive, votable: votable, user: user2) }
  let!(:vote3) { create(:vote, :negative, votable: votable, user: user3) }
  let!(:vote4) { create(:vote, :negative, votable: votable, user: user4) }
  let!(:vote5) { create(:vote, :negative, votable: votable, user: user5) }

  describe 'Vote.like' do
    let!(:vote) { Vote.like }

    it 'returns instance with .value = 1' do
      expect(vote).to be_a(Vote)
      expect(vote.value).to eq 1
    end
  end

  describe 'Vote.dislike' do
    let!(:vote) { Vote.dislike }

    it 'returns instance with .value = -1' do
      expect(vote).to be_a(Vote)
      expect(vote.value).to eq -1
    end
  end
end

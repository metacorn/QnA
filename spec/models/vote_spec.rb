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

  describe 'positive scope' do
    it 'returns only positive votes' do
      expect(votable.votes.where(value: '1')).to match_array([vote1, vote2])
    end
  end

  describe 'negative scope' do
    it 'returns only negative votes' do
      expect(votable.votes.where(value: '-1')).to match_array([vote3, vote4, vote5])
    end
  end

  describe 'negative scope' do
    it 'returns only users vote' do
      expect(votable.votes.by_user(user1)).to match_array([vote1])
      expect(votable.votes.by_user(user2)).to match_array([vote2])
      expect(votable.votes.by_user(user3)).to match_array([vote3])
      expect(votable.votes.by_user(user4)).to match_array([vote4])
      expect(votable.votes.by_user(user5)).to match_array([vote5])
    end
  end
end

require 'rails_helper'

RSpec.shared_examples_for "votable" do
  it { should have_many(:votes).dependent(:destroy) }

  let(:model) { described_class }
  (1..5).each { |i| let("user#{i}".to_sym) { create(:user) } }
  let(:votable) { build(model.to_s.underscore.to_sym, user: user1) }
  let!(:vote_positive1) { create(:vote, :positive, votable: votable, user: user2) }
  let!(:vote_positive2) { create(:vote, :positive, votable: votable, user: user3) }
  let!(:vote_negative1) { create(:vote, :negative, votable: votable, user: user4) }

  describe '#rating' do
    it 'shows rating equals 1' do
      expect(votable.reload.rating).to eq 1
    end
  end

  describe '#cancel_vote_of(user)' do
    it "cancels existing vote of passing user" do
      votable.cancel_vote_of(user2)

      expect {
        vote_positive1.reload
      }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it 'returns false for non existing vote of passing user' do
      expect(votable.cancel_vote_of(user5)).to eq false
    end
  end
end

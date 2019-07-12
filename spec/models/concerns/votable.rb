require 'rails_helper'

RSpec.shared_examples_for "votable" do
  it { should have_many(:votes).dependent(:destroy) }

  let(:model) { described_class }
  (1..4).each { |i| let("user#{i}".to_sym) { create(:user) } }
  let(:votable) { build(model.to_s.underscore.to_sym, user: user1) }

  describe '#rating' do
    let!(:vote_positive1) { create(:vote, :positive, votable: votable, user: user2) }
    let!(:vote_positive2) { create(:vote, :positive, votable: votable, user: user3) }
    let!(:vote_negative1) { create(:vote, :negative, votable: votable, user: user4) }

    it 'shows rating equals 1' do
      expect(votable.reload.rating).to eq 1
    end
  end
end

require 'rails_helper'

RSpec.describe Answer, type: :model do
  it { should belong_to :question }
  it { should belong_to :user }
  it { should have_many(:links).dependent(:destroy) }
  it { should have_one(:badge).dependent(:destroy) }

  it { should accept_nested_attributes_for :links }

  it { should validate_presence_of :body }
  it { should validate_length_of(:body).is_at_least(50) }

  it { should have_many(:files_attachments) }

  it_behaves_like "votable"
  it_behaves_like "commentable"

  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:answer1) { create(:answer, question: question, user: user) }
  let(:answer2) { create(:answer, question: question, user: user) }
  let!(:badge) { create(:badge, question: question) }

  describe '#mark_best' do
    it 'marks one answer as the best' do
      answer1.mark_as_best

      expect(answer1).to be_best
      expect(answer2).to_not be_best
    end

    it 'marks one answer for question with badge as the best' do
      answer2.mark_as_best

      expect(answer2.badge).to eq badge
      expect(user).to be_owner(badge)
    end
  end

  describe 'default_scope order' do
    it 'sorting answers with the best as the first' do
      answer1.mark_as_best

      expect(answer1.question.answers).to eq [answer1, answer2]
    end
  end
end

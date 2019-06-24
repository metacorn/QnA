require 'rails_helper'

RSpec.describe Answer, type: :model do
  it { should belong_to :question }
  it { should belong_to :user }

  it { should validate_presence_of :body }

  it { should validate_length_of(:body).is_at_least(50) }

  describe '#mark_best' do
    let(:user) { create(:user) }
    let(:question) { create(:question, user: user) }
    let(:answer1) { create(:answer, question: question, user: user) }
    let(:answer2) { create(:answer, question: question, user: user) }

    it 'marks one answer' do
      answer1.mark_as_best

      expect(answer1).to be_best
    end

    it 'marks one and then another answer' do
      answer1.mark_as_best
      answer2.mark_as_best
      answer1.reload

      expect(answer1).to_not be_best
      expect(answer2).to be_best
    end
  end
end

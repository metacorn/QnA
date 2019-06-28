require 'rails_helper'

RSpec.describe Answer, type: :model do
  it { should belong_to :question }
  it { should belong_to :user }
  it { should validate_presence_of :body }
  it { should validate_length_of(:body).is_at_least(50) }

  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:answer1) { create(:answer, question: question, user: user) }
  let(:answer2) { create(:answer, question: question, user: user) }

  describe '#mark_best' do
    it 'marks one answer as the best' do
      answer1.mark_as_best

      expect(answer1).to be_best
      expect(answer2).to_not be_best
    end
  end

  describe 'default_scope order' do
    it 'sorting answers with the best as the first' do
      answer1.mark_as_best

      expect(answer1.question.answers).to eq [answer1, answer2]
    end
  end

  it 'has many attached files' do
    expect(Answer.new.files).to be_an_instance_of(ActiveStorage::Attached::Many)
  end
end

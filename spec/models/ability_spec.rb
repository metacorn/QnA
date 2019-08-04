require 'rails_helper'

RSpec.describe Ability do
  subject(:ability) { Ability.new(user) }

  describe 'for guests' do
    let(:user) { nil }

    it { should be_able_to :read, :all }
    it { should_not be_able_to :manage, :all }
  end

  describe 'for admins' do
    let(:user) { create :user, admin: true }

    it { should be_able_to :manage, :all }
  end

  describe 'for users' do
    let(:user) { create :user }
    let(:other_user) { create :user }
    let(:question) { create(:question, user: user) }
    let(:other_question) { create(:question, user: other_user) }
    let(:answer) { create(:answer, question: other_question, user: user) }
    let(:other_answer) { create(:answer, question: question, user: other_user) }
    let(:own_answer_to_his_question) { create(:answer, question: question, user: user) }

    it { should be_able_to :read, :all }
    it { should_not be_able_to :manage, :all }

    it { should be_able_to :create, Question }
    it { should be_able_to :create, Answer }
    it { should be_able_to :create, Comment }

    it { should be_able_to :manage, question }
    it { should_not be_able_to :manage, other_question }

    it { should be_able_to :manage, answer }
    it { should_not be_able_to :manage, other_answer }

    it { should be_able_to :vote_up, other_question }
    it { should be_able_to :vote_down, other_question }
    it { should be_able_to :cancel_vote, other_question }

    it { should_not be_able_to :vote_up, question }
    it { should_not be_able_to :vote_down, question }
    it { should_not be_able_to :cancel_vote, question }

    it { should be_able_to :vote_up, other_answer }
    it { should be_able_to :vote_down, other_answer }
    it { should be_able_to :cancel_vote, other_answer }

    it { should_not be_able_to :vote_up, answer }
    it { should_not be_able_to :vote_down, answer }
    it { should_not be_able_to :cancel_vote, answer }

    it { should be_able_to :mark, other_answer }
    it { should_not be_able_to :mark, own_answer_to_his_question }

    it { should be_able_to :destroy, create(:link, :valid, linkable: answer) }
    it { should_not be_able_to :destroy, create(:link, :valid, linkable: other_answer) }
  end
end

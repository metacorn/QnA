require 'rails_helper'

RSpec.shared_examples_for "voted" do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:question1) { create(:question, user: user1) }
  let(:question2) { create(:question, user: user2) }

  describe 'POST #vote_up' do
    context 'authenticated user' do
      before { login user1 }

      it "votes for another's user question" do
        expect {
          post :vote_up, params: { id: question2.id }, format: :json
        }.to change(question2, :rating).by(1)
      end

      it "tries to vote for his own question" do
        expect {
          post :vote_up, params: { id: question1.id }, format: :json
        }.to_not change(question1, :rating)
      end
    end

    context 'unauthenticated user' do
      it "tries to vote for someone's question" do
        expect {
          post :vote_up, params: { id: question1.id }, format: :json
        }.to_not change(question1, :rating)
      end
    end
  end

  describe 'POST #vote_down' do
    context 'authenticated user' do
      before { login user1 }

      it "votes against another's user question" do
        expect {
          post :vote_down, params: { id: question2.id }, format: :json
        }.to change(question2, :rating).by(-1)
      end

      it "tries to vote against his own question" do
        expect {
          post :vote_down, params: { id: question1.id }, format: :json
        }.to_not change(question1, :rating)
      end
    end

    context 'unauthenticated user' do
      it "tries to vote against someone's question" do
        expect {
          post :vote_up, params: { id: question1.id }, format: :json
        }.to_not change(question1, :rating)
      end
    end
  end
end

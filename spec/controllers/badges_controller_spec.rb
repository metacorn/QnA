require 'rails_helper'

RSpec.describe BadgesController, type: :controller do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:question1) { create(:question, user: user2) }
  let(:question2) { create(:question, user: user2) }
  let(:answer1) { create(:answer, question: question1, user: user1) }
  let(:answer2) { create(:answer, question: question2, user: user1) }
  let!(:badge1) { create(:badge, question: question1, answer: answer1, user: user1) }
  let!(:badge2) { create(:badge, question: question2, answer: answer2, user: user1) }

  describe 'GET #index' do
    context 'authenticated user' do
      before { login(user1) }
      before { get :index, params: { user_id: user1.id } }

      it "populates an array with all user's badges" do
        expect(assigns(:badges)).to match_array([badge1, badge2])
      end

      it 'renders index view' do
        expect(response).to render_template :index
      end
    end

    context 'unauthenticated user' do
      before { get :index, params: { user_id: user1.id } }

      it "does not populate an array with all user's badges" do
        expect(assigns(:badges)).to be_nil
      end
    end
  end
end

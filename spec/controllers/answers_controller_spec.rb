require 'rails_helper'
require 'byebug'

RSpec.describe AnswersController, type: :controller do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }

  describe 'GET #new' do
    before { login(user) }
    before { get :new, params: { question_id: question.id } }

    it 'assigns a new answer to @answer' do
      expect(assigns(:answer)).to be_a_new(Answer)
    end

    it 'renders new view' do
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    before { login(user) }

    context 'with valid attributes' do
      it 'saves a new answer in the database' do
        expect { post :create, params: { question_id: question.id, answer: attributes_for(:answer) } }.to change(question.answers, :count).by(1)
      end

      it 'redirects to question show view' do
        post :create, params: { question_id: question.id, answer: attributes_for(:answer) }

        expect(response).to redirect_to question
      end

      it 'creates answer by the name of logged user' do
        new_answer_params = attributes_for(:answer)
        post :create, params: { question_id: question.id, answer: new_answer_params }
        created_answer = question.answers.find_by! new_answer_params

        expect(created_answer.user).to eq user
      end
    end

    context 'with invalid attributes' do
      it 'does not save a new answer with short body in the database' do
        expect { post :create, params: { question_id: question.id, answer: attributes_for(:answer, :invalid) } }.to_not change(Answer, :count)
      end

      it 'renders new view' do
        post :create, params: { question_id: question.id, answer: attributes_for(:answer, :invalid) }
        expect(response).to redirect_to question
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:question) { create(:question, user: user) }
    let!(:answer) { create(:answer, question: question, user: user) }
    let(:user2) { create(:user) }
    let!(:answer2) { create(:answer, question: question, user: user2) }

    before { login(user) }

    it 'deletes the answer' do
      expect {
        delete :destroy, params: { id: answer }
      }.to change(Answer, :count).by(-1)
      expect { answer.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'redirects to Question show view' do
      delete :destroy, params: { id: answer }

      expect(response).to redirect_to question
    end

    it "tries to delete another user's answer" do
      expect { delete :destroy, params: { id: answer2 } }.to_not change(Answer, :count)
    end
  end
end

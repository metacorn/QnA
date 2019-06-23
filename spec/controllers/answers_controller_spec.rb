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
        expect { post :create, params: { question_id: question.id, answer: attributes_for(:answer), format: :js } }.to change(question.answers, :count).by(1)
      end

      it 'creates answer by the name of logged user' do
        new_answer_params = attributes_for(:answer)
        post :create, params: { question_id: question.id, answer: new_answer_params, format: :js }
        created_answer = question.answers.find_by! new_answer_params

        expect(created_answer.user).to eq user
      end
    end

    context 'with invalid attributes' do
      it 'does not save a new answer with short body in the database' do
        expect { post :create, params: { question_id: question.id, answer: attributes_for(:answer, :invalid), format: :js } }.to_not change(Answer, :count)
      end

      it 'renders create template' do
        post :create, params: { question_id: question.id, answer: attributes_for(:answer, :invalid), format: :js }
        expect(response).to render_template 'create'
      end
    end
  end

  describe 'DELETE #destroy' do
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

  describe 'PATCH #update' do
    let!(:answer) { create(:answer, question: question, user: user) }
    let!(:new_body) { "New answer's body #{"a" * 32}" }

    before { login(user) }

    context 'with valid attributes' do
      it 'updates an answer' do
        patch :update, params: { id: answer, answer: { body: new_body } }, format: :js
        answer.reload

        expect(answer.body).to eq new_body
      end

      it 'renders update view' do
        patch :update, params: { id: answer, answer: { body: new_body } }, format: :js

        expect(response).to render_template :update
      end
    end

    context 'with invalid attributes' do
      it 'does not update an answer' do
        expect {
          patch :update,
          params: { id: answer, answer: attributes_for(:answer, :invalid) },
          format: :js
        }.to_not change(answer, :body)
      end

      it 'renders update view' do
        patch :update,
        params: { id: answer, answer: attributes_for(:answer, :invalid) },
        format: :js

        expect(response).to render_template :update
      end
    end
  end
end

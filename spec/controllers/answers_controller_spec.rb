require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:question1) { create(:question1) }

  describe 'GET #new' do
    before { get :new, params: { question_id: question1.id } }

    it 'assigns a new answer to @answer' do
      expect(assigns(:answer)).to be_a_new(Answer)
    end

    it 'renders new view' do
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'saves a new question in the database' do
        expect { post :create, params: { question_id: question1.id, answer: attributes_for(:answer) } }.to change(question1.answers, :count).by(1)
      end

      it 'redirects to question show view' do
        post :create, params: { question_id: question1.id, answer: attributes_for(:answer) }
        expect(response).to redirect_to question1
      end
    end

    context 'with invalid attributes' do
      it 'does not save a new answer with short body in the database' do
        expect { post :create, params: { question_id: question1.id, answer: attributes_for(:answer, :invalid) } }.to_not change(question1.answers, :count)
      end

      it 'renders new view' do
        post :create, params: { question_id: question1.id, answer: attributes_for(:answer, :invalid) }
        expect(response).to render_template :new
      end
    end
  end
end

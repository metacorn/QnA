require 'rails_helper'
require 'byebug'

RSpec.describe AnswersController, type: :controller do
  let(:user1) { create(:user) }
  let(:question1) { create(:question, user: user1) }

  describe 'GET #new' do
    before { login(user1) }
    before { get :new, params: { question_id: question1.id } }

    it 'assigns a new answer to @answer' do
      expect(assigns(:answer)).to be_a_new(Answer)
    end

    it 'renders new view' do
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    before { login(user1) }

    context 'with valid attributes' do
      it 'saves a new answer in the database' do
        expect {
          post :create,
            params: {
              question_id: question1.id,
              answer: attributes_for(:answer)
            },
            format: :js
        }.to change(question1.answers, :count).by(1)
      end

      it 'creates answer by the name of logged user' do
        new_answer_params = attributes_for(:answer)
        post :create,
          params: {
            question_id: question1.id,
            answer: new_answer_params
          },
          format: :js
        created_answer = question1.answers.find_by! new_answer_params

        expect(user1).to be_owned(created_answer)
      end

      it 'renders create template', js: true do
        post :create,
            params: {
              question_id: question1.id,
              answer: attributes_for(:answer)
            },
            format: :js

        expect(response).to render_template 'create'
      end
    end

    context 'with invalid attributes' do
      it 'does not save a new answer with short body in the database' do
        expect {
          post :create,
            params: {
              question_id: question1.id,
              answer: attributes_for(:answer, :invalid)
            },
            format: :js
        }.to_not change(Answer, :count)
      end

      it 'renders create template' do
        post :create,
          params: {
            question_id: question1.id,
            answer: attributes_for(:answer, :invalid)
          },
          format: :js
        expect(response).to render_template 'create'
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:answer1) { create(:answer, question: question1, user: user1) }
    let(:user2) { create(:user) }
    let!(:answer2) { create(:answer, question: question1, user: user2) }

    context 'authenticated user' do
      before { login(user1) }

      it "deletes user's answer" do
        expect {
          delete :destroy, params: { id: answer1 }, format: :js
        }.to change(question1.answers, :count).by(-1)
        expect { answer1.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'renders destroy template' do
        delete :destroy, params: { id: answer1 }, format: :js

        expect(response).to render_template 'destroy'
      end

      it "tries to delete another user's answer" do
        expect {
          delete :destroy, params: { id: answer2 }, format: :js
        }.to_not change(Answer, :count)
      end
    end

    context 'authenticated user' do
      it "tries to delete an answer" do
        expect {
          delete :destroy, params: { id: answer2 }, format: :js
        }.to_not change(Answer, :count)
      end
    end
  end

  describe 'PATCH #update' do
    let(:user2) { create(:user) }
    let!(:answer1) { create(:answer, question: question1, user: user1) }
    let!(:answer2) { create(:answer, question: question1, user: user2) }
    let!(:new_body) { "New answer's body #{"a" * 32}" }

    context 'authenticated user' do
      before { login(user1) }

      context 'with valid attributes' do
        it "updates user's answer" do
          patch :update,
            params: { id: answer1, answer: { body: new_body } },
            format: :js
          answer1.reload

          expect(answer1.body).to eq new_body
        end

        it "does not update another user's answer" do
          expect {
            patch :update,
              params: { id: answer2, answer: { body: new_body } },
              format: :js
          }.to_not change { answer2.reload.body }
        end

        it 'renders update view' do
          patch :update,
            params: { id: answer1, answer: { body: new_body} },
            format: :js

          expect(response).to render_template :update
        end
      end

      context 'with invalid attributes' do
        it 'does not update an answer' do
          expect {
            patch :update,
              params: { id: answer1, answer: attributes_for(:answer, :invalid) },
              format: :js
          }.to_not change { answer1.reload.body }
        end

        it 'renders update view' do
          patch :update,
          params: { id: answer1, answer: attributes_for(:answer, :invalid) },
          format: :js

          expect(response).to render_template :update
        end
      end
    end

    context 'unauthenticated user' do
      it 'does not update an answer' do
        expect {
          patch :update,
            params: { id: answer1, answer: attributes_for(:answer) },
            format: :js
        }.to_not change { answer1.reload.body }
      end
    end
  end

  describe 'POST #mark' do
    let(:user2) { create(:user) }
    let!(:question2) { create(:question, user: user2) }
    let!(:answer1) { create(:answer, question: question2, user: user1) }
    let!(:answer2) { create(:answer, question: question1, user: user2) }
    let!(:answer3) { create(:answer, question: question1, user: user2) }

    context 'authenticated user' do
      before { login(user1) }

      it 'marks answers to his question' do
        post :mark, params: { id: answer2 }, format: :js
        answer2.reload

        expect(answer2).to be_best

        post :mark, params: { id: answer3 }, format: :js
        answer2.reload
        answer3.reload

        expect(answer2).to_not be_best
        expect(answer3).to be_best
      end

      it "tries to mark an answer to another user's question" do
        post :mark, params: { id: answer1 }, format: :js

        expect(answer2).to_not be_best
      end
    end

    context 'unauthenticated user' do
      it "tries to mark an answer to another user's question" do
        post :mark, params: { id: answer1 }, format: :js

        expect(answer2).to_not be_best
      end
    end
  end
end

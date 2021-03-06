require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do
  it_behaves_like 'voted'

  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }

  describe 'GET #index' do
    let(:questions) { create_list(:question, 5, user: user) }

    before { get :index }

    it 'populates an array with all questions' do
      expect(assigns(:questions)).to match_array(questions)
    end

    it 'renders index view' do
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    before { get :show, params: { id: question } }

    it 'assigns the requested question to @question' do
      expect(assigns(:question)).to eq question
    end

    it 'assigns new links to @answer.links' do
      expect(assigns(:answer).links.first).to be_a_new(Link)
    end

    it 'renders show view' do
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    before { login(user) }
    before { get :new }

    it 'assigns a new question to @question' do
      expect(assigns(:question)).to be_a_new(Question)
    end

    it 'assigns new links to @question.links' do
      expect(assigns(:question).links.first).to be_a_new(Link)
    end

    it 'renders new view' do
      expect(response).to render_template :new
    end
  end

  describe 'GET #edit' do
    before { login(user) }
    before { get :edit, params: { id: question } }

    it 'assigns the requested question to @question' do
      expect(assigns(:question)).to eq question
    end

    it 'renders edit view' do
      expect(response).to render_template :edit
    end
  end

  describe 'POST #create' do
    before { login(user) }

    context 'with valid attributes' do
      it 'saves a new question in the database' do
        expect {
          post :create, params: { question: attributes_for(:question) }
        }.to change(Question, :count).by(1)
      end

      it 'redirects to show view' do
        post :create, params: { question: attributes_for(:question) }

        expect(response).to redirect_to assigns(:question)
      end

      it 'creates a question by the name of logged user' do
        new_question_params = attributes_for(:question)
        post :create, params: { question: new_question_params }
        created_question = Question.find_by! new_question_params

        expect(created_question.user).to eq user
      end
    end

    context 'with invalid attributes' do
      it 'does not save a new question in the database' do
        expect {
          post :create, params: { question: attributes_for(:question, :invalid) }
        }.to_not change(Question, :count)
      end

      it 'renders new view' do
        post :create, params: { question: attributes_for(:question, :invalid) }
        expect(response).to render_template :new
      end
    end
  end

  describe 'PATCH #update' do
    context 'authenticated user' do
      let(:user2) { create(:user) }
      let(:question2) { create(:question, user: user2) }
      let(:new_title) { "New title for the first question" }
      let(:new_body) { "#{"b" * 50}" }

      before { login(user) }

      context 'with valid attributes' do
        it 'changes question attributes' do
          patch :update,
            params: {
              id: question,
              question: { title: new_title, body: new_body }
            },
            format: :js
          question.reload

          expect(question.title).to eq(new_title)
          expect(question.body).to eq(new_body)
        end

        it "tries to update another user's question" do
          expect {
            patch :update,
              params: {
                id: question2,
                question: attributes_for(:question)
              },
              format: :js
          }.to_not change { question.reload.updated_at }
        end

        it 'renders update view' do
          patch :update,
            params: {
              id: question,
              question: attributes_for(:question)
            },
            format: :js

          expect(response).to render_template :update
        end
      end

      context 'with invalid attributes' do
        it 'does not change the question' do
          expect {
            patch :update,
              params: {
                id: question,
                question: attributes_for(:question, :invalid)
              },
              format: :js
          }.to_not change { question.reload.updated_at }
        end

        it 'renders update view' do
          patch :update,
            params: {
              id: question,
              question: attributes_for(:question, :invalid)
            },
            format: :js

          expect(response).to render_template :update
        end
      end
    end

    context 'unauthenticated user' do
      it 'tries to change question attributes' do
        expect {
          patch :update,
            params: {
              id: question,
              question: attributes_for(:question)
            },
            format: :js
        }.to_not change { question.reload.updated_at }
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:user2) { create(:user) }
    let!(:question) { create(:question, user: user) }
    let!(:question2) { create(:question, user: user2) }

    context 'authenticated user' do
      before { login(user) }

      it 'deletes the question' do
        expect {
          delete :destroy, params: { id: question }
        }.to change(Question, :count).by(-1)
      end

      it 'redirects to index' do
        delete :destroy, params: { id: question }

        expect(response).to redirect_to questions_path
      end

      it "tries to delete another user's question" do
        expect {
          delete :destroy, params: { id: question2 }
        }.to_not change(Question, :count)
      end
    end

    it "unauthenticated user tries to delete another user's question" do
      expect {
        delete :destroy, params: { id: question }, format: :js
      }.to_not change(Question, :count)
    end
  end
end

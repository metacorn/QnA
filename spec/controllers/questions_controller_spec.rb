require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do
  let(:question1) { create(:question1) }

  describe 'GET #index' do
    let(:question2) { create(:question2) }

    before { get :index }

    it 'populates an array with all questions' do
      expect(assigns(:questions)).to match_array([question1, question2])
    end

    it 'renders index view' do
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    before { get :show, params: { id: question1 } }

    it 'assigns the requested question to @question' do
      expect(assigns(:question)).to eq question1
    end

    it 'renders show view' do
      expect(response).to render_template :show
    end
  end

  describe 'GET #new' do
    before { get :new }

    it 'assigns a new question to @question' do
      expect(assigns(:question)).to be_a_new(Question)
    end

    it 'renders new view' do
      expect(response).to render_template :new
    end
  end

  describe 'GET #edit' do
    before { get :edit, params: { id: question1 } }

    it 'assigns the requested question to @question' do
      expect(assigns(:question)).to eq question1
    end

    it 'renders edit view' do
      expect(response).to render_template :edit
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'saves a new question in the database' do
        expect { post :create, params: { question: attributes_for(:question1) } }.to change(Question, :count).by(1)
      end

      it 'redirects to show view' do
        post :create, params: { question: attributes_for(:question1) }
        expect(response).to redirect_to assigns(:question)
      end
    end

    context 'with invalid attributes' do
      it 'does not save a new question with short title in the database' do
        expect { post :create, params: { question: attributes_for(:question1, :invalid) } }.to_not change(Question, :count)
      end

      it 'renders new view' do
        post :create, params: { question: attributes_for(:question1, :invalid) }
        expect(response).to render_template :new
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      it 'assigns the requested question to @question' do
        patch :update, params: { id: question1, question: attributes_for(:question1) }
        expect(assigns(:question)).to eq question1
      end

      it 'changes question attributes' do
        patch :update, params: { id: question1, question: { title: "New title for the first question", body: "#{"b" * 50}" } }
        question1.reload

        expect(question1.title).to eq("New title for the first question")
        expect(question1.body).to eq("#{"b" * 50}")
      end

      it 'redirects to updated question' do
        patch :update, params: { id: question1, question: attributes_for(:question1) }
        expect(response).to redirect_to question1
      end
    end
    context 'with invalid attributes' do
      before { patch :update, params: { id: question1, question: attributes_for(:question1, :invalid) }
 }

      it 'does not change the question' do
        question1.reload
        expect(question1.title).to eq("Title of the first question")
        expect(question1.body).to eq("#{"a" * 50}")
      end

      it 'renders edit view' do
        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:question1) { create(:question1) }

    it 'deletes the question' do
      expect { delete :destroy, params: { id: question1 } }.to change(Question, :count).by(-1)
    end

    it 'redirects to index' do
      delete :destroy, params: { id: question1 }
      expect(response).to redirect_to questions_path
    end
  end
end

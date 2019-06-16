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
        expect { post :create, params: { question: attributes_for(:question1, :short_title) } }.to_not change(Question, :count)
      end
      it 'does not save a new question with long title in the database' do
        expect { post :create, params: { question: attributes_for(:question1, :long_title) } }.to_not change(Question, :count)
      end
      it 'does not save a new question with not unique title in the database' do
        post :create, params: { question: attributes_for(:question1) }
        expect { post :create, params: { question: attributes_for(:question2, :the_same_title_as_of_the_first_question) } }.to_not change(Question, :count)
      end
      it 're-renders new view' do
        post :create, params: { question: attributes_for(:question1, :short_title) }
        expect(response).to render_template :new
      end
    end
  end
end
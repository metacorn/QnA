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
end

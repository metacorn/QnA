require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do
  describe 'GET #index' do
    it 'populates an array with all questions' do
      question1 = FactoryBot.create(:question1)
      question2 = FactoryBot.create(:question2)

      get :index

      expect(assigns(:questions)).to match_array([question1, question2])
    end

    it 'renders index view' do
      get :index

      expect(response).to render_template :index
    end
  end
end

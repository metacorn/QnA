require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  describe 'GET #new' do
    let(:question1) { create(:question1) }
    before { get :new, params: { question_id: question1.id } }

    it 'assigns a new answer to @answer' do
      expect(assigns(:answer)).to be_a_new(Answer)
    end
    it 'renders new view' do
      expect(response).to render_template :new
    end
  end
end

require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:user1) { create(:user) }
  let(:question1) { create(:question, user: user1) }
  let(:valid_params) do
    { question_id: question1.id, comment: { body: "1234567890" } }
  end
  let(:invalid_params) do
    { question_id: question1.id, comment: { body: "00000" } }
  end

  describe 'POST #create' do
    context 'authenticated user' do
      before { login(user1) }

      context 'with valid attributes' do
        it 'saves a new comment in the database' do
          expect {
            post :create, params: valid_params, format: :js
          }.to change(question1.comments, :count).by(1)
        end

        it 'creates comment by the name of logged user' do
          post :create, params: valid_params, format: :js
          created_comment = question1.comments.find_by! valid_params[:comment]

          expect(user1).to be_owner(created_comment)
        end

        it 'renders create template', js: true do
          post :create, params: valid_params, format: :js

          expect(response).to render_template 'create'
        end
      end

      context 'with invalid attributes' do
        it 'does not save a new comment with short body in the database' do
          expect {
            post :create, params: invalid_params, format: :js
          }.to_not change(Comment, :count)
        end

        it 'renders create template' do
          post :create, params: invalid_params, format: :js

          expect(response).to render_template 'create'
        end
      end
    end

    context 'unauthenticated user' do
      it 'tries to add a comment' do
        expect {
            post :create, params: valid_params, format: :js
          }.to_not change(question1.comments, :count)
      end
    end
  end
end

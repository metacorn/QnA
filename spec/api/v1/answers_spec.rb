require 'rails_helper'

describe 'Answers API', type: :request do
  let(:headers) { { "ACCEPT" => 'application/json' } }

  describe 'GET /api/v1/answers/:id' do
    let(:user) { create(:user) }
    let(:access_token) { create(:access_token) }
    let(:question) { create(:question, user: user) }
    let(:answer) { create(:answer, question: question, user: user) }
    let(:api_path) { "/api/v1/answers/#{answer.id}" }

    it_behaves_like 'API_authorable' do
      let(:meth) { :get }
    end

    before do
      create(:link, :valid, linkable: answer)
      create(:link, :valid_gist, linkable: answer)
      create_list(:comment, 3, commentable: answer, user: user)
    end

    it_behaves_like 'API_readable' do
      let(:resource) { answer }
      let(:resource_attrs) { %w[id body created_at updated_at] }
    end

    it 'contains question object' do
      get api_path, params: { access_token: access_token.token }, headers: headers

      expect(json['answer']['question']['id']).to eq answer.question.id
    end
  end

  describe 'POST /api/v1/questions/:id/answers' do
    let(:user) { create(:user) }
    let(:access_token) { create(:access_token) }
    let(:question) { create(:question, user: user) }
    let(:api_path) { "/api/v1/questions/#{question.id}/answers" }

    it_behaves_like 'API_authorable' do
      let(:meth) { :post }
    end

    it_behaves_like 'API_creatable' do
      let(:resource) { :answer }
      let(:countable) { question.answers }
      let(:invalid_error_msg) { "Body is too short (minimum is 50 characters)" }
    end
  end

  describe 'PATCH /api/v1/answers/:id' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:access_token) { create(:access_token, resource_owner_id: user.id) }
    let(:question) { create(:question, user: user) }
    let(:answer) { create(:answer, question: question, user: user) }
    let(:api_path) { "/api/v1/answers/#{answer.id}" }

    it_behaves_like 'API_authorable' do
      let(:meth) { :patch }
    end

    it_behaves_like 'API_updatable' do
      let(:resource) { answer }
      let(:other_user_resource) { create(:answer, question: question, user: other_user) }
      let(:resource_attrs) { %w[id body best created_at] }
      let(:invalid_error_msg) { "Body is too short (minimum is 50 characters)" }
    end
  end

  describe 'DELETE /api/v1/answers/:id' do
    let(:user) { create(:user) }
    let(:access_token) { create(:access_token, resource_owner_id: user.id) }
    let(:question) { create(:question, user: user) }
    let(:answer) { create(:answer, question: question, user: user) }
    let(:api_path) { "/api/v1/answers/#{answer.id}" }

    it_behaves_like 'API_authorable' do
      let(:meth) { :delete }
    end

    context 'authorized' do
      context "for user's answer" do
        before do
          delete  api_path, params: { access_token: access_token.token }, headers: headers
        end

        it 'returns 200 status' do
          expect(response).to be_successful
        end

        it 'returns a message' do
          expect(json['messages']).to include "Answer was successfully deleted."
        end

        it 'deletes an answer' do
          expect { answer.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "for another user's answer" do
        let(:other_user) { create(:user) }
        let(:other_answer) { create(:answer, question: question, user: other_user) }
        let(:other_answer_api_path) { "/api/v1/answers/#{other_answer.id}" }

        before do
          delete  other_answer_api_path, params: { access_token: access_token.token }, headers: headers
        end

        it 'returns 403 status' do
          expect(response.status).to eq 403
        end

        it 'does not deletes an answer' do
          expect { answer.reload }.to_not raise_error
        end
      end
    end
  end
end

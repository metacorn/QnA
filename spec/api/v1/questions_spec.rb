require 'rails_helper'

describe 'Questions API', type: :request do
  let(:headers) { { "ACCEPT" => 'application/json' } }
  let(:meth) { :get }

  describe 'GET /api/v1/questions' do
    let(:access_token) { create(:access_token) }
    let(:user) { create(:user) }
    let(:questions) { create_list(:question, 5, user: user) }
    let!(:answers) { create_list(:answer, 4, question: questions.first, user: user) }
    let(:api_path) { '/api/v1/questions' }

    it_behaves_like 'API_authorable'

    context 'authorized' do
      before do
        get api_path, params: { access_token: access_token.token }, headers: headers
      end

      it 'returns 200 status' do
        expect(response).to be_successful
      end

      it_behaves_like 'API_readable_collection' do
        let(:collection) { questions }
        let(:collection_member_attrs) { %w[id title body created_at updated_at] }
        let(:response_collection) { json['questions'] }
      end

      it 'contains short titles' do
        questions.size.times do |i|
          expect(json['questions'][i]['short_title']).to eq questions[i].title.truncate(10)
        end
      end

      it 'contains user object' do
        questions.size.times do |i|
          expect(json['questions'][i]['user']['id']).to eq questions[i].user.id
        end
      end

      describe 'answers' do
        it_behaves_like 'API_readable_collection' do
          let(:collection) { answers }
          let(:collection_member_attrs) { %w[id body created_at updated_at] }
          let(:response_collection) { json['questions'].first['answers'] }
        end
      end
    end
  end

  describe 'GET /api/v1/questions/:id' do
    let(:user) { create(:user) }
    let(:access_token) { create(:access_token) }
    let(:question) { create(:question, :with_attachments, user: user) }
    let(:api_path) { "/api/v1/questions/#{question.id}" }

    it_behaves_like 'API_authorable'

    before do
      create(:link, :valid, linkable: question)
      create(:link, :valid_gist, linkable: question)
      create_list(:comment, 3, commentable: question, user: user)
    end

    it_behaves_like 'API_readable' do
      let(:resource) { question }
      let(:resource_attrs) { %w[id title body created_at updated_at] }
    end
  end

  describe 'GET /api/v1/questions/:id/answers' do
    let(:user) { create(:user) }
    let(:access_token) { create(:access_token) }
    let(:question) { create(:question, user: user) }
    let!(:answers) { create_list(:answer, 5, question: question, user: user) }
    let(:answers_response) { json['answers'] }
    let(:api_path) { "/api/v1/questions/#{question.id}/answers" }

    it_behaves_like 'API_authorable'

    context 'authorized' do
      before do
        get api_path, params: { access_token: access_token.token }, headers: headers
      end

      it 'returns 200 status' do
        expect(response).to be_successful
      end

      it_behaves_like 'API_readable_collection' do
        let(:collection) { answers }
        let(:collection_member_attrs) { %w[id body created_at updated_at] }
        let(:response_collection) { json['answers'] }
      end
    end
  end

  describe 'POST /api/v1/questions/' do
    let(:user) { create(:user) }
    let(:access_token) { create(:access_token) }
    let(:api_path) { "/api/v1/questions" }

    it_behaves_like 'API_authorable' do
      let(:meth) { :post }
    end

    it_behaves_like 'API_creatable' do
      let(:resource) { :question }
      let(:countable) { Question }
      let(:invalid_error_msg) { "Title is too short (minimum is 15 characters)" }
    end
  end

  describe 'PATCH /api/v1/questions/:id' do
    let(:user) { create(:user) }
    let(:access_token) { create(:access_token, resource_owner_id: user.id) }
    let(:question) { create(:question, user: user) }
    let(:api_path) { "/api/v1/questions/#{question.id}" }

    it_behaves_like 'API_authorable' do
      let(:meth) { :patch }
    end

    it_behaves_like 'API_updatable' do
      let(:resource) { question }
      let(:other_user) { create(:user) }
      let(:other_user_resource) { create(:question, user: other_user) }
      let(:other_user_resource_api_path) { "/api/v1/questions/#{other_user_resource.id}" }
      let(:resource_attrs) { %w[id title body created_at] }
      let(:invalid_error_msg) { "Title is too short (minimum is 15 characters)" }
    end
  end

  describe 'DELETE /api/v1/questions/:id' do
    let(:user) { create(:user) }
    let(:access_token) { create(:access_token, resource_owner_id: user.id) }
    let(:question) { create(:question, user: user) }
    let(:api_path) { "/api/v1/questions/#{question.id}" }

    it_behaves_like 'API_authorable' do
      let(:meth) { :delete }
    end

    it_behaves_like 'API_destroyable' do
      let(:resource) { question }
      let(:other_user) { create(:user) }
      let(:other_user_resource) { create(:question, user: other_user) }
      let(:other_user_resource_api_path) { "/api/v1/questions/#{other_user_resource.id}" }
      let(:successfully_destroyed_msg) { "Question was successfully deleted." }
    end
  end
end

require 'rails_helper'

describe 'Questions API', type: :request do
  let(:headers) { { "CONTENT_TYPE" => "application/json",
                    "ACCEPT" => 'application/json' } }

  describe 'GET /api/v1/answers/:id' do
    let(:user) { create(:user) }
    let(:access_token) { create(:access_token) }
    let(:question) { create(:question, user: user) }
    let(:answer) { create(:answer, question: question, user: user) }
    let(:files) { answer.files }
    let!(:links) { [create(:link, :valid, linkable: answer),
                    create(:link, :valid_gist, linkable: answer)] }
    let!(:comments) { create_list(:comment, 3, commentable: answer, user: user) }
    let(:answer_response) { json['answer'] }
    let(:api_path) { "/api/v1/answers/#{answer.id}" }

    it_behaves_like 'API_authorable' do
      let(:meth) { 'get' }
    end

    before do
      get api_path, params: { access_token: access_token.token }, headers: headers
    end

    it 'returns 200 status' do
      expect(response).to be_successful
    end

    it 'returns answer' do
      %w[id body created_at updated_at].each do |attr|
        expect(answer_response[attr]).to eq answer.send(attr).as_json
      end
    end

    it 'contains user object' do
      expect(answer_response['user']['id']).to eq answer.user.id
    end

    it 'contains question object' do
      expect(answer_response['question']['id']).to eq answer.question.id
    end

    it 'contails all files list' do
      expect(answer_response['files'].map { |f| f['id'] }).to match_array files.pluck(:id)
    end

    it 'returns all files public fields' do
      files.size.times do |i|
        %w[id created_at].each do |attr|
          expect(answer_response['files'][i][attr]).to eq files[i].send(attr).as_json
        end

        expect(answer_response['files'][i]['filename']).to eq files[i].blob['filename']
        expect(answer_response['files'][i]['url']).to eq Rails.application.routes.url_helpers.rails_blob_path(files[i], only_path: true)
      end
    end

    it 'contains all links list' do
      expect(answer_response['links'].map { |l| l['id'] }).to match_array links.pluck(:id)
    end

    it 'returns all links public fields' do
      links.size.times do |i|
        %w[id name url created_at updated_at].each do |attr|
          expect(answer_response['links'][i][attr]).to eq links[i].send(attr).as_json
        end
      end
    end

    it 'contains all comments list' do
      expect(answer_response['comments'].map { |c| c['id'] }).to match_array comments.pluck(:id)
    end

    it 'returns all comments public fields' do
      comments.size.times do |i|
        %w[id user_id body created_at updated_at].each do |attr|
          expect(answer_response['comments'][i][attr]).to eq comments[i].send(attr).as_json
        end
      end
    end
  end
end

require 'rails_helper'

describe 'Questions API', type: :request do
  let(:headers) { { "CONTENT_TYPE" => "application/json",
                    "ACCEPT" => 'application/json' } }

  describe 'GET /api/v1/questions' do
    let(:api_path) { '/api/v1/questions' }

    it_behaves_like 'API_authorable' do
      let(:meth) { 'get' }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let(:user) { create(:user) }
      let(:questions) { create_list(:question, 5, user: user) }
      let!(:answers) { create_list(:answer, 4, question: questions.first, user: user) }

      before do
        get api_path, params: { access_token: access_token.token }, headers: headers
      end

      it 'returns 200 status' do
        expect(response).to be_successful
      end

      it 'returns list of questions' do
        expect(json['questions'].size).to eq 5
      end

      it 'returns all public fields' do
        5.times do |i|
          %w[id title body created_at updated_at].each do |attr|
            expect(json['questions'][i][attr]).to eq questions[i].send(attr).as_json
          end
        end
      end

      it 'contains short titles' do
        5.times do |i|
          expect(json['questions'][i]['short_title']).to eq questions[i].title.truncate(10)
        end
      end

      it 'contains user object' do
        5.times do |i|
          expect(json['questions'][i]['user']['id']).to eq questions[i].user.id
        end
      end

      describe 'answers' do
        let(:answers_response) { json['questions'].first['answers'] }

        it 'returns list of answers' do
          expect(json['questions'].first['answers'].size).to eq 4
        end

        it 'returns all public fields' do
          4.times do |i|
            %w[id body best user_id created_at updated_at].each do |attr|
              expect(answers_response[i][attr]).to eq answers[i].send(attr).as_json
            end
          end
        end
      end
    end
  end

  describe 'GET /api/v1/questions/:id' do
    let(:user) { create(:user) }
    let(:access_token) { create(:access_token) }
    let(:question) { create(:question, :with_attachments, user: user) }
    let(:files) { question.files }
    let!(:links) { [create(:link, :valid, linkable: question),
                    create(:link, :valid_gist, linkable: question)] }
    let!(:comments) { create_list(:comment, 3, commentable: question, user: user) }
    let(:question_response) { json['question'] }
    let(:api_path) { "/api/v1/questions/#{question.id}" }

    it_behaves_like 'API_authorable' do
      let(:meth) { 'get' }
    end

    before do
      get api_path, params: { access_token: access_token.token }, headers: headers
    end

    it 'returns 200 status' do
      expect(response).to be_successful
    end

    it 'returns question' do
      %w[id title body created_at updated_at].each do |attr|
        expect(question_response[attr]).to eq question.send(attr).as_json
      end
    end

    it 'contains user object' do
      expect(question_response['user']['id']).to eq question.user.id
    end

    it 'contails all files list' do
      expect(question_response['files'].map { |f| f['id'] }).to match_array files.pluck(:id)
    end

    it 'returns all files public fields' do
      files.size.times do |i|
        %w[id created_at].each do |attr|
          expect(question_response['files'][i][attr]).to eq files[i].send(attr).as_json
        end

        expect(question_response['files'][i]['filename']).to eq files[i].blob['filename']
        expect(question_response['files'][i]['url']).to eq Rails.application.routes.url_helpers.rails_blob_path(files[i], only_path: true)
      end
    end

    it 'contains all links list' do
      expect(question_response['links'].map { |l| l['id'] }).to match_array links.pluck(:id)
    end

    it 'returns all links public fields' do
      links.size.times do |i|
        %w[id name url created_at updated_at].each do |attr|
          expect(question_response['links'][i][attr]).to eq links[i].send(attr).as_json
        end
      end
    end

    it 'contains all comments list' do
      expect(question_response['comments'].map { |c| c['id'] }).to match_array comments.pluck(:id)
    end

    it 'returns all comments public fields' do
      comments.size.times do |i|
        %w[id user_id body created_at updated_at].each do |attr|
          expect(question_response['comments'][i][attr]).to eq comments[i].send(attr).as_json
        end
      end
    end
  end

  describe 'GET /api/v1/questions/:id/answers' do
    let(:user) { create(:user) }
    let(:access_token) { create(:access_token) }
    let(:question) { create(:question, user: user) }
    let!(:answers) { create_list(:answer, 5, question: question, user: user) }
    let(:answers_response) { json['answers'] }
    let(:api_path) { "/api/v1/questions/#{question.id}/answers" }

    it_behaves_like 'API_authorable' do
      let(:meth) { 'get' }
    end

    before do
      get api_path, params: { access_token: access_token.token }, headers: headers
    end

    it 'returns 200 status' do
      expect(response).to be_successful
    end

    it 'contains all question answers list' do
      expect(answers_response.map { |a| a['id']}).to match_array answers.pluck(:id)
    end

    it 'returns all question answers public fields' do
      answers.size.times do |i|
        %w[id user_id body best created_at updated_at].each do |attr|
          expect(answers_response[i][attr]).to eq answers[i].send(attr).as_json
        end
      end
    end
  end
end

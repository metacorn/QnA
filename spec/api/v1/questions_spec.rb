require 'rails_helper'

describe 'Questions API', type: :request do
  let(:headers) { { "ACCEPT" => 'application/json' } }

  describe 'GET /api/v1/questions' do
    let(:access_token) { create(:access_token) }
    let(:user) { create(:user) }
    let(:questions) { create_list(:question, 5, user: user) }
    let!(:answers) { create_list(:answer, 4, question: questions.first, user: user) }
    let(:api_path) { '/api/v1/questions' }

    it_behaves_like 'API_authorable' do
      let(:meth) { :get }
    end

    context 'authorized' do
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
    let(:api_path) { "/api/v1/questions/#{question.id}" }

    it_behaves_like 'API_authorable' do
      let(:meth) { :get }
    end

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

    it_behaves_like 'API_authorable' do
      let(:meth) { :get }
    end

    context 'authorized' do
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

  describe 'POST /api/v1/questions/' do
    let(:user) { create(:user) }
    let(:access_token) { create(:access_token) }
    let(:api_path) { "/api/v1/questions" }

    it_behaves_like 'API_authorable' do
      let(:meth) { :post }
    end

    context 'authorized' do
      context 'with valid question data' do
        let(:question_params) { attributes_for(:question) }
        let(:post_request) { post api_path,
                                  params: { access_token: access_token.token,
                                            question: question_params },
                                  headers: headers }

        it 'returns 200 status' do
          post_request

          expect(response).to be_successful
        end

        it 'creates a question' do
          expect { post_request }.to change(Question, :count).by(1)
        end

        it 'returns new question data' do
          post_request

          %w[title body].each do |attr|
            expect(json['question'][attr]).to eq question_params[attr.to_sym]
          end
        end
      end

      context 'with invalid question data' do
        let(:post_request) {  post  api_path,
                                    params: { access_token: access_token.token,
                                              question: attributes_for(:question, :invalid) },
                                    headers: headers }

        it 'does not create a question' do
          expect { post_request }.to_not change(Question, :count)
        end

        it 'returns error messages' do
          post_request

          expect(json['messages']).to include "Title is too short (minimum is 15 characters)"
        end
      end
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

    context 'authorized' do
      context "for user's question" do
        context 'with valid question data' do
          before do
            patch api_path,
                  params: { access_token: access_token.token,
                            question: attributes_for(:question) },
                  headers: headers
          end

          it 'returns 200 status' do
            expect(response).to be_successful
          end

          it 'updates a question' do
            question.reload

            %w[id title body created_at].each do |attr|
              expect(json['question'][attr]).to eq question.send(attr).as_json
            end
          end
        end

        context 'with invalid question data' do
          let(:patch_request) { patch api_path,
                                      params: { access_token: access_token.token,
                                                question: attributes_for(:question, :invalid) },
                                      headers: headers }

          it 'does not update a question' do
            expect { patch_request }.to_not change(question, :updated_at)
          end

          it 'returns error messages' do
            patch_request

            expect(json['messages']).to include "Title is too short (minimum is 15 characters)"
          end
        end
      end

      context "for another user's question" do
        let(:other_user) { create(:user) }
        let(:other_question) { create(:question, user: other_user) }
        let(:other_question_api_path) { "/api/v1/questions/#{other_question.id}" }
        let(:patch_request) { patch other_question_api_path,
                                    params: { access_token: access_token.token,
                                              question: attributes_for(:question) },
                                    headers: headers }

        it 'returns 403 status' do
          patch_request

          expect(response.status).to eq 403
        end

        it 'does not update a question' do
          expect { patch_request }.to_not change(other_question, :updated_at)
        end
      end
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

    context 'authorized' do
      context "for user's question" do
        before do
          delete  api_path, params: { access_token: access_token.token }, headers: headers
        end

        it 'returns 200 status' do
          expect(response).to be_successful
        end

        it 'returns a message' do
          expect(json['messages']).to include "Question was successfully deleted."
        end

        it 'deletes a question' do
          expect { question.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "for another user's question" do
        let(:other_user) { create(:user) }
        let(:other_question) { create(:question, user: other_user) }
        let(:other_question_api_path) { "/api/v1/questions/#{other_question.id}" }

        before do
          delete  other_question_api_path, params: { access_token: access_token.token }, headers: headers
        end

        it 'returns 403 status' do
          expect(response.status).to eq 403
        end

        it 'does not deletes a question' do
          expect { question.reload }.to_not raise_error
        end
      end
    end
  end
end

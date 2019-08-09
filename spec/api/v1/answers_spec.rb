require 'rails_helper'

describe 'Questions API', type: :request do
  let(:headers) { { "ACCEPT" => 'application/json' } }

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
      let(:meth) { :get }
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

  describe 'POST /api/v1/questions/:id/answers' do
    let(:user) { create(:user) }
    let(:access_token) { create(:access_token) }
    let(:question) { create(:question, user: user) }
    let(:api_path) { "/api/v1/questions/#{question.id}/answers" }

    it_behaves_like 'API_authorable' do
      let(:meth) { :post }
    end

    context 'authorized' do
      context 'with valid answer data' do
        let(:answer_params) { attributes_for(:answer) }
        let(:post_request) { post api_path,
                                  params: { access_token: access_token.token,
                                            question: question,
                                            answer: answer_params },
                                  headers: headers }

        it 'returns 200 status' do
          post_request

          expect(response).to be_successful
        end

        it 'creates an answer' do
          expect { post_request }.to change(question.answers, :count).by(1)
        end

        it 'returns new answer data' do
          post_request

          %w[body].each do |attr|
            expect(json['answer'][attr]).to eq answer_params[attr.to_sym]
          end
        end
      end

      context 'with invalid answer data' do
        let(:post_request) { post api_path,
                                  params: { access_token: access_token.token,
                                            question: question,
                                            answer: attributes_for(:answer, :invalid) },
                                  headers: headers }

        it 'does not create a question' do
          expect { post_request }.to_not change(question.answers, :count)
        end

        it 'returns error messages' do
          post_request

          expect(json['messages']).to include "Body is too short (minimum is 50 characters)"
        end
      end
    end
  end

  describe 'PATCH /api/v1/answers/:id' do
    let(:user) { create(:user) }
    let(:access_token) { create(:access_token, resource_owner_id: user.id) }
    let(:question) { create(:question, user: user) }
    let(:answer) { create(:answer, question: question, user: user) }
    let(:api_path) { "/api/v1/answers/#{answer.id}" }

    it_behaves_like 'API_authorable' do
      let(:meth) { :patch }
    end

    context 'authorized' do
      context "for user's answer" do
        context 'with valid answer data' do
          before do
            patch api_path,
                  params: { access_token: access_token.token,
                            answer: attributes_for(:answer) },
                  headers: headers
          end

          it 'returns 200 status' do
            expect(response).to be_successful
          end

          it 'updates a question' do
            answer.reload

            %w[id body created_at].each do |attr|
              expect(json['answer'][attr]).to eq answer.send(attr).as_json
            end
          end
        end

        context 'with invalid answer data' do
          let(:patch_request) { patch api_path,
                                      params: { access_token: access_token.token,
                                                answer: attributes_for(:answer, :invalid) },
                                      headers: headers }

          it 'does not update an answer' do
            expect { patch_request }.to_not change(answer, :updated_at)
          end

          it 'returns error messages' do
            patch_request

            expect(json['messages']).to include "Body is too short (minimum is 50 characters)"
          end
        end
      end

      context "for another user's question" do
        let(:other_user) { create(:user) }
        let(:other_answer) { create(:answer, question: question, user: other_user) }
        let(:other_answer_api_path) { "/api/v1/answers/#{other_answer.id}" }
        let(:patch_request) { patch other_answer_api_path,
                                    params: { access_token: access_token.token,
                                              answer: attributes_for(:answer) },
                                    headers: headers }

        it 'returns 403 status' do
          patch_request

          expect(response.status).to eq 403
        end

        it 'does not update a question' do
          expect { patch_request }.to_not change(other_answer, :updated_at)
        end
      end
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

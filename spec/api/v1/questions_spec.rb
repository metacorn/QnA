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
end

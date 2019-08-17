require 'rails_helper'

describe 'Profile API', type: :request do
  let(:headers) { { "CONTENT_TYPE" => "application/json",
                    "ACCEPT" => 'application/json' } }

  describe 'GET /api/v1/profiles/me' do
    let(:api_path) { '/api/v1/profiles/me' }

    it_behaves_like 'API_authorable' do
      let(:meth) { 'get' }
    end

    context 'authorized' do
      let(:me) { create(:user) }
      let(:access_token) { create(:access_token, resource_owner_id: me.id) }

      before do
        get api_path, params: { access_token: access_token.token }, headers: headers
      end

      it 'returns 200 status' do
        expect(response).to be_successful
      end

      it 'returns all public fields' do
        %w[id email admin created_at updated_at].each do |attr|
          expect(json['user'][attr]).to eq me.send(attr).as_json
        end
      end

      it 'does not return private fields' do
        %w[password encrypted_password].each do |attr|
          expect(json['user']).to_not have_key(attr)
        end
      end
    end
  end

  describe 'GET /api/v1/profiles' do
    let(:api_path) { '/api/v1/profiles' }

    it_behaves_like 'API_authorable' do
      let(:meth) { 'get' }
    end

    context 'authorized' do
      let(:me) { create(:user) }
      let!(:others) { create_list(:user, 3) }
      let(:access_token) { create(:access_token, resource_owner_id: me.id) }

      before do
        get api_path, params: { access_token: access_token.token }, headers: headers
      end

      it 'returns 200 status' do
        expect(response).to be_successful
      end

      it 'returns all other users' do
        expect(json['users'].map { |u| u['id'] }).to match_array others.pluck(:id)
      end

      it 'does not return user who does request' do
        expect(json['users'].map { |u| u['id'] }).to_not include(me.id)
      end

      it 'returns all public fields' do
        3.times do |i|
          %w[id email admin created_at updated_at].each do |attr|
            expect(json['users'][i][attr]).to eq others[i].send(attr).as_json
          end
        end
      end

      it 'does not return private fields' do
        3.times do |i|
          %w[password encrypted_password].each do |attr|
            expect(json['users'][i]).to_not have_key(attr)
          end
        end
      end
    end
  end
end

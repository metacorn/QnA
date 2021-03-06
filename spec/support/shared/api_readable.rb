require 'rails_helper'

RSpec.shared_examples_for "API_readable" do
  context 'authorized' do
    let(:resource_response) { json[resource.class.to_s.downcase] }

    before do
      get api_path, params: { access_token: access_token.token }, headers: headers
    end

    it 'returns 200 status' do
      expect(response).to be_successful
    end

    it 'returns resource object' do
      resource_attrs.each do |attr|
        expect(resource_response[attr]).to eq resource.send(attr).as_json
      end
    end

    it 'contains author object' do
      expect(resource_response['user']['id']).to eq resource.user.id
    end

    it 'contails object files list' do
      expect(resource_response['files'].map { |f| f['id'] }).to match_array resource.files.pluck(:id)
    end

    it 'returns object files public fields' do
      resource.files.each_with_index do |resource_file, index|
        resource_response_file = resource_response['files'][index]

        expect(resource_response_file['id']).to eq resource_file.id
        expect(resource_response_file['created_at']).to eq resource_file.created_at.as_json
        expect(resource_response_file['filename']).to eq resource_file.blob['filename']
        expect(resource_response_file['url']).to eq Rails.application.routes.url_helpers.rails_blob_path(resource_file, only_path: true)
      end
    end

    it 'contains object links list' do
      expect(resource_response['links'].map { |l| l['id'] }).to match_array resource.links.pluck(:id)
    end

    it 'returns object links public fields' do
      resource.links.size.times do |i|
        %w[id name url created_at updated_at].each do |attr|
          expect(resource_response['links'][i][attr]).to eq resource.links[i].send(attr).as_json
        end
      end
    end

    it 'contains object comments list' do
      expect(resource_response['comments'].map { |c| c['id'] }).to match_array resource.comments.pluck(:id)
    end

    it 'returns object comments public fields' do
      resource.comments.size.times do |i|
        %w[id user_id body created_at updated_at].each do |attr|
          expect(resource_response['comments'][i][attr]).to eq resource.comments[i].send(attr).as_json
        end
      end
    end
  end
end

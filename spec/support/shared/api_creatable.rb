require 'rails_helper'

RSpec.shared_examples_for "API_creatable" do
  context 'authorized' do
    let(:resource_params) { attributes_for(resource) }
    let(:post_request) { post api_path,
                              params: { access_token: access_token.token,
                                        resource => resource_params },
                              headers: headers }

    context 'with valid resource data' do
      it 'returns 200 status' do
        post_request

        expect(response).to be_successful
      end

      it 'creates a resource' do
        expect { post_request }.to change(countable, :count).by(1)
      end

      it 'returns new resource data' do
        post_request

        %w[title body].each do |attr|
          expect(json[resource.to_s][attr]).to eq resource_params[attr.to_sym]
        end
      end
    end

    context 'with invalid resource data' do
      let(:resource_params) { attributes_for(resource, :invalid) }
      let(:post_request) { post api_path,
                                params: { access_token: access_token.token,
                                          resource => resource_params },
                                headers: headers }

      it 'does not create a resource' do
        expect { post_request }.to_not change(countable, :count)
      end

      it 'returns error messages' do
        post_request

        expect(json['messages']).to include invalid_error_msg
      end
    end
  end
end

require 'rails_helper'

RSpec.shared_examples_for "API_updatable" do
  let(:resource_type) { resource.class.to_s.downcase.to_sym }

  context 'authorized' do
    context "for author's resource" do
      context 'with valid resource data' do
        before do
          patch api_path,
                params: { access_token: access_token.token,
                          resource_type => attributes_for(resource_type) },
                headers: headers
        end

        it 'returns 200 status' do
          expect(response).to be_successful
        end

        it 'updates a resource' do
          resource.reload

          resource_attrs.each do |attr|
            expect(json[resource_type.to_s][attr]).to eq resource.send(attr).as_json
          end
        end
      end

      context 'with invalid resource data' do
        let(:patch_request) { patch api_path,
                                    params: { access_token: access_token.token,
                                              resource_type => attributes_for(resource_type, :invalid) },
                                    headers: headers }

        it 'does not update a resource' do
          expect { patch_request }.to_not change(resource, :updated_at)
        end

        it 'returns error messages' do
          patch_request

          expect(json['messages']).to include invalid_error_msg
        end
      end
    end

    context "for another user's resource" do
      let(:patch_request) { patch other_user_resource_api_path,
                                  params: { access_token: access_token.token,
                                            resource_type => attributes_for(resource_type) },
                                  headers: headers }

      it 'returns 403 status' do
        patch_request

        expect(response.status).to eq 403
      end

      it 'does not update a resource' do
        expect { patch_request }.to_not change(other_user_resource, :updated_at)
      end
    end
  end
end

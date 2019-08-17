require 'rails_helper'

RSpec.shared_examples_for "API_destroyable" do
  context 'authorized' do
    context "for user's resource" do
      before do
        delete  api_path, params: { access_token: access_token.token }, headers: headers
      end

      it 'returns 200 status' do
        expect(response).to be_successful
      end

      it 'returns a message' do
        expect(json['messages']).to include successfully_destroyed_msg
      end

      it 'deletes a resource' do
        expect { resource.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context "for another user's resource" do
      before do
        delete  other_user_resource_api_path, params: { access_token: access_token.token }, headers: headers
      end

      it 'returns 403 status' do
        expect(response.status).to eq 403
      end

      it 'does not delete a resource' do
        expect { resource.reload }.to_not raise_error
      end
    end
  end
end

require 'rails_helper'

RSpec.shared_examples_for "API_authorable" do
  context 'unauthorized' do
    it 'returns 401 status if there is no access_token' do
      do_request(meth, api_path, headers: headers)

      expect(response.status).to eq 401
    end

    it 'returns 401 status if access_token is invalid' do
      do_request(meth, api_path, params: { 'access_token' => '123456' }, headers: headers)

      expect(response.status).to eq 401
    end
  end
end

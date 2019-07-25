require 'rails_helper'

RSpec.describe "Services::GistContent" do
  let(:service_with_valid_gist_id) { Services::GistContent.new('99f81dab3792c594fd02eb84ab53f85e') }
  let(:service_with_invalid_gist_id) { Services::GistContent.new('1234567890') }

  describe '#content' do
    it 'returns content in case of valid gist id' do
      expect(service_with_valid_gist_id.content).to eq [{filename: 'File 1', content: 'Content of file 1'}, {filename: 'File 2', content: 'Content of file 2'}]
    end

    it 'returns nil in case of invalid gist id' do
      expect(service_with_invalid_gist_id.content).to be_nil
    end
  end
end

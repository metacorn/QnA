require 'rails_helper'

RSpec.describe Link, type: :model do
  it { should belong_to :linkable }

  it { should validate_presence_of :name }
  it { should validate_presence_of :url }

  let(:valid_link) { build(:link, :valid, :linkable) }
  let(:invalid_link) { build(:link, :invalid, :linkable) }
  let(:valid_gist_link) { build(:link, :valid_gist, :linkable) }
  let(:invalid_gist_link) { build(:link, :invalid_gist, :linkable) }

  it 'validates valid url format' do
    expect(valid_link).to be_valid
  end

  it 'not validates invalid url format' do
    expect(invalid_link).to be_invalid
  end

  describe '#gist?' do
    it 'confirms valid gist link' do
      expect(valid_gist_link).to be_gist
    end

    it 'does not confirm invalid gist link' do
      expect(invalid_gist_link).to_not be_gist
    end

    it 'does not confirm not gist link' do
      expect(valid_link).to_not be_gist
    end
  end

  describe '#gist_id' do
    it 'returns id for gist link' do
      expect(valid_gist_link.gist_id).to eq '99f81dab3792c594fd02eb84ab53f85e'
    end

    it 'returns nil for not gist link' do
      expect(valid_link.gist_id).to be_nil
    end
  end

  describe '#gist_content' do
    it 'returns array of hashes with necessary keys and values for valid gist link' do
      expect(valid_gist_link.gist_content).to eq [{filename: 'File 1', content: 'Content of file 1'}, {filename: 'File 2', content: 'Content of file 2'}]
    end

    it 'returns nil for invalid gist link' do
      expect(invalid_gist_link.gist_content).to be_nil
    end

    it 'returns nil for not gist link' do
      expect(valid_link.gist_content).to be_nil
    end
  end
end

require 'rails_helper'

RSpec.shared_examples_for "API_readable_collection" do
  it 'contains all collection members list' do
    expect(response_collection.map { |q| q['id']}).to match_array collection.pluck(:id)
  end

  it 'contains all collection members public fields' do
    collection.size.times do |i|
      collection_member_attrs.each do |attr|
        expect(response_collection[i][attr]).to eq collection[i].send(attr).as_json
      end
    end
  end
end

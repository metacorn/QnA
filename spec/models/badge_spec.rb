require 'rails_helper'

RSpec.describe Badge, type: :model do
  it { should belong_to :question }
  it { should belong_to(:answer).optional }
  it { should belong_to(:user).optional }
  it { should have_one :image_attachment }
  it { should validate_presence_of :name }
end

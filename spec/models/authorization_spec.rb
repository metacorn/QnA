require 'rails_helper'

RSpec.describe Authorization, type: :model do
  it { should belong_to(:user).dependent(:destroy) }
  it { should validate_presence_of :provider }
  it { should validate_presence_of :uid }
end

require 'rails_helper'

RSpec.describe Authorization, type: :model do
  it { should belong_to(:user) }
  it { should validate_presence_of :provider }
  it { should validate_presence_of :uid }
  it { should validate_uniqueness_of(:uid).scoped_to(:provider).with_message('authentication with these provider and uid is already in use') }
  it { should validate_presence_of :oauth_email }
  it { should validate_uniqueness_of(:oauth_email).scoped_to(:provider).with_message('authentication with these provider and e-mail is already in use') }
  it { should allow_value('user@example.com').for(:oauth_email) }
  it { should_not allow_value('user@examplecom').for(:oauth_email) }

  describe '.init_confirmation' do
    context 'valid authorization' do
      let!(:valid_authorization) { build(:authorization, :with_user) }
      before { valid_authorization.init_confirmation }

      it 'updates confirmation_token attribute' do
        expect(valid_authorization.confirmation_token).to be_a String
      end

      it 'updates confirmation_sent_at token attribute' do
        expect(valid_authorization.confirmation_sent_at).to be
      end

      it 'saves valid authorization to db' do
        expect(valid_authorization).to_not be_new_record
      end
    end

    context 'valid authorization' do
      let!(:invalid_authorization) { build(:authorization) }

      it 'does not save authorization to db' do
        expect {
          invalid_authorization.init_confirmation
        }.to_not change(invalid_authorization, :new_record?)
      end

      it 'returns false' do
        expect(invalid_authorization.init_confirmation).to eq false
      end
    end
  end
end

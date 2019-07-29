require 'rails_helper'

RSpec.describe "Services::FindForOauth" do
  let!(:user) { create(:user) }
  let(:auth) { OmniAuth::AuthHash.new(provider: 'github', uid: '123') }
  subject { Services::FindForOauth.new(auth) }

  context 'user already has authorization' do
    it 'returns this user' do
      user.authorizations.create(provider: 'github', uid: '123', oauth_email: user.email)

      expect(subject.call).to eq user
    end
  end

  context 'user has no authorization' do
    context 'user already exists' do
      let(:auth) {
        OmniAuth::AuthHash.new( provider: 'github',
                                uid: '123',
                                info: { email: user.email })
      }

      it 'does not create a new user' do
        expect { subject.call }.to_not change(User, :count)
      end

      it 'creates an authorization for this user' do
        expect { subject.call }.to change(user.authorizations, :count).by(1)
      end

      it 'creates an authorization with proper provider and uid attributes' do
        authorization = subject.call.authorizations.last

        expect(authorization.provider).to eq auth.provider
        expect(authorization.uid).to eq auth.uid
      end

      it 'returns this user' do
        expect(subject.call).to eq user
      end
    end

    context 'user does not exist' do
      let(:auth) {
        OmniAuth::AuthHash.new(provider: 'github',
                               uid: '123',
                               info: { email: '123@example.com' })
      }

      it 'creates a new user' do
        expect { subject.call }.to change(User, :count).by(1)
      end

      it 'returns a user' do
        expect(subject.call).to be_a User
      end

      it "fills this user's email" do
        user = subject.call

        expect(user.email).to eq auth.info.email
      end

      it 'creates an authorization for this user' do
        user = subject.call

        expect(user.authorizations).to_not be_empty
      end

      it 'creates an authorization with proper provider and uid attributes' do
        authorization = subject.call.authorizations.last

        expect(authorization.provider).to eq auth.provider
        expect(authorization.uid).to eq auth.uid
      end
    end
  end
end

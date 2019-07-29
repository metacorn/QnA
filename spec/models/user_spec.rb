require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many :questions }
  it { should have_many :answers }
  it { should have_many :comments }
  it { should have_many(:badges).dependent(:destroy) }
  it { should have_many(:votes).dependent(:destroy) }
  it { should have_many(:authorizations).dependent(:destroy) }

  it { should validate_presence_of :email }
  it { should validate_presence_of :password }

  describe '#owner?' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:question1) { create(:question, user: user1) }
    let(:question2) { create(:question, user: user2) }

    it 'check if user is owner of resource created by himself' do
      expect(user1).to be_owner(question1)
    end

    it 'check if user is not owner of resource created by another user' do
      expect(user1).to_not be_owner(question2)
    end
  end

  describe '.find_for_oauth' do
    let!(:user) { create(:user) }
    let(:auth) { OmniAuth::AuthHash.new(provider: 'github', uid: '123') }
    let(:service) { double('Services::FindForOauth') }

    it 'calls Services::FindForOauth' do
      expect(Services::FindForOauth).to receive(:new).with(auth).and_return(service)
      expect(service).to receive(:call)
      User.find_for_oauth(auth)
    end
  end

  describe '.check_email_set_user' do
    let(:user) { create(:user) }
    let(:another_email) { 'user2@user.com' }

    context 'with email of existing user' do
      it 'returns existing user' do
        expect(User.check_email_set_user(user.email)).to_not be_new_record
      end

      it 'returns user-owner of this email' do
        expect(User.check_email_set_user(user.email)).to eq user
      end

      it "does not change user's confirmation status" do
        expect {
          User.check_email_set_user(user.email)
        }.to_not change(user, :confirmed?)
      end
    end

    context 'with email not used by any user' do
      it 'returns new user without saving to db' do
        expect(User.check_email_set_user(another_email)).to be_new_record
      end

      it 'returns user with this email' do
        expect(User.check_email_set_user(another_email).email).to eq another_email
      end

      it "skips user's confirmation status" do
        expect(User.check_email_set_user(another_email)).to be_confirmed
      end
    end
  end

  describe '#create_auth' do
    let(:user) { create(:user) }
    let(:valid_session_auth) { { "provider" => 'github', "uid" => "1121212" } }
    let(:invalid_session_auth) { { invalid: "data" } }
    let(:email) { 'user2@user.com' }

    context 'with valid session[:auth] data' do
      it "creates new authentication with oauth email matching to main user's email" do
        expect(user.create_auth(user.email, valid_session_auth)).to be_persisted
      end

      it "creates new authentication with oauth email not matching to main user's email" do
        expect(user.create_auth(email, valid_session_auth)).to be_persisted
      end
    end

    context 'with invalid session[:auth] data' do
      it "does not create new authentication with oauth email matching to main user's email" do
        expect {
          user.create_auth(user.email, invalid_session_auth)
        }.to_not change(Authorization, :count)
      end

      it "does not create new authentication with oauth email not matching to main user's email" do
        expect {
          user.create_auth(email, invalid_session_auth)
        }.to_not change(Authorization, :count)
      end
    end
  end
end

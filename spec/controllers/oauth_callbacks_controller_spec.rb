require 'rails_helper'

RSpec.describe OauthCallbacksController, type: :controller do
  before { @request.env["devise.mapping"] = Devise.mappings[:user] }

  describe 'GitHub' do
    it 'finds user by oauth data' do
      oauth = mock_auth_hash(provider: :github)
      allow(request.env).to receive(:[]).and_call_original
      allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth)
      expect(User).to receive(:find_for_oauth)
      get :github
    end

    context 'user exists' do
      let!(:user) { create(:user) }
      let!(:oauth) { mock_auth_hash(provider: :github, email: user.email) }

      before do
        allow(request.env).to receive(:[]).and_call_original
        allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth)
        get :github
      end

      it 'logs user in' do
        expect(subject.current_user).to eq user
      end

      it 'redirects to root path' do
        expect(response).to redirect_to root_path
      end
    end

    context 'user does not exists' do
      let!(:oauth) { mock_auth_hash(provider: :github) }

      before do
        allow(request.env).to receive(:[]).and_call_original
        allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth)
        get :github
      end

      it 'logs user in' do
        user = User.find_by(email: oauth.info.email)

        expect(subject.current_user).to eq user
      end

      it 'redirects to root path' do
        expect(response).to redirect_to root_path
      end
    end

    context 'invalid credentials' do
      let!(:oauth) { mock_auth_hash(provider: :github, validness: false) }

      before do
        allow(request.env).to receive(:[]).and_call_original
        allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth)
        get :github
      end

      it 'informs about something wrong' do
        expect(response).to redirect_to root_path
        expect(flash[:alert]).to eq 'Something was wrong!'
      end
    end
  end

  describe 'VK' do
    it 'finds user by oauth data' do
      oauth = mock_auth_hash(provider: :vkontakte)
      allow(request.env).to receive(:[]).and_call_original
      allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth)
      expect(User).to receive(:find_for_oauth)
      get :vkontakte
    end

    context 'VK does not return email' do
      let!(:oauth) { mock_auth_hash(provider: :vkontakte, email: nil) }

      before do
        allow(request.env).to receive(:[]).and_call_original
        allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth)
        get :vkontakte
      end

      context 'for the first attempt to login' do
        it 'informs about sending a mail with instructions' do
          expect(flash[:notice]).to eq "Vkontakte did not provide your email. Please enter your email for sending you confirmation instructions."
        end

        it 'renders email confirmation template' do
          expect(response).to render_template 'omniauth_callbacks/confirm_email'
        end
      end

      context 'for the next attempts to login without confirmation' do
        before do
          post :confirm_email,  params: { oauth_email: 'mock@user.com' },
                                session: { auth: request.env['omniauth.auth'] }
          get :vkontakte
        end

        it 'reminds about sending a mail with instructions' do
          expect(flash[:notice]).to eq "We have already sent you confirmation instructions to mock@user.com. Please check your email."
        end

        it 'renders email confirmation template' do
          expect(response).to render_template 'omniauth_callbacks/confirm_email'
        end
      end

      context 'for the next attempts to login with confirmation' do
        before do
          post :confirm_email, params: {  oauth_email: 'mock@user.com' },
                                          session: { auth: request.env['omniauth.auth'] }
          Authorization.find_by(provider: oauth.provider,
                                uid: oauth.uid).update!(confirmed_at: Time.now)
          get :vkontakte
        end

        it 'logs user in' do
          user = User.find_by(email: 'mock@user.com')
          expect(subject.current_user).to eq user
        end
      end
    end

    context 'VK returns email' do
      context 'user exists' do
        let!(:user) { create(:user) }
        let!(:oauth) { mock_auth_hash(provider: :vkontakte, email: user.email) }

        before do
          allow(request.env).to receive(:[]).and_call_original
          allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth)
          get :vkontakte
        end

        it 'logs user in' do
          expect(subject.current_user).to eq user
        end

        it 'redirects to root path' do
          expect(response).to redirect_to root_path
        end
      end

      context 'user does not exists' do
        let!(:oauth) { mock_auth_hash(provider: :vkontakte) }

        before do
          allow(request.env).to receive(:[]).and_call_original
          allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth)
          get :vkontakte
        end

        it 'logs user in' do
          user = User.find_by(email: oauth.info.email)

          expect(subject.current_user).to eq user
        end

        it 'redirects to root path' do
          expect(response).to redirect_to root_path
        end
      end

      context 'invalid credentials' do
        let!(:oauth) { mock_auth_hash(provider: :vkontakte, validness: false) }

        before do
          allow(request.env).to receive(:[]).and_call_original
          allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth)
          get :vkontakte
        end

        it 'informs about something wrong' do
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to eq 'Something was wrong!'
        end
      end
    end
  end

  describe 'POST #confirm_email' do
    before do
      oauth = mock_auth_hash(provider: :github, email: nil)
      allow(request.env).to receive(:[]).and_call_original
      allow(request.env).to receive(:[]).with('omniauth.auth').and_return(oauth)
    end

    context 'with valid email owned by confirmed user' do
      let!(:user) { create(:user, email: 'mock@user.com') }
      let(:post_request) {
        post :confirm_email,
          params: { oauth_email: 'mock@user.com' },
          session: { auth: request.env['omniauth.auth'] }
      }

      before do
        get :github
      end

      it 'creates authorization associated with user' do
        authorizations = User.find_by(email: 'mock@user.com').authorizations.where(oauth_email: 'mock@user.com', provider: 'github')

        expect { post_request }.to change(authorizations, :count).by(1)
      end

      it 'and this authorization is not confirmed yet' do
        post_request
        authorization = User.find_by(email: 'mock@user.com').authorizations.find_by(oauth_email: 'mock@user.com', provider: 'github')

        expect(authorization).to_not be_confirmed
      end

      it 'sends confirmation instructions to this email' do
        expect { post_request }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'with valid email not used bu any of users' do
      let(:post_request) {
        post :confirm_email,
          params: { oauth_email: 'mock@user.com' },
          session: { auth: request.env['omniauth.auth'] }
      }
      before do
        get :github
      end

      it 'creates user with this email' do
        post_request
        user = User.find_by(email: 'mock@user.com')

        expect(user).to be
      end

      it 'creates authorization associated with user' do
        post_request
        authorization = User.find_by(email: 'mock@user.com').authorizations.find_by(oauth_email: 'mock@user.com', provider: 'github')

        expect(authorization).to be
      end

      it 'and this authorization is not confirmed yet' do
        post_request
        authorization = User.find_by(email: 'mock@user.com').authorizations.find_by(oauth_email: 'mock@user.com', provider: 'github')

        expect(authorization).to_not be_confirmed
      end

      it 'sends confirmation instructions to this email' do
        expect { post_request }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'with invalid email' do
      it 'does not create user' do
        expect {
          post :confirm_email,
            params: { oauth_email: 'mock@usercom' },
            session: { auth: request.env['omniauth.auth'] }
        }.to_not change(User, :count)
      end

      it 'does not create authorization' do
        expect {
          post :confirm_email,
            params: { oauth_email: 'mock@usercom' },
            session: { auth: request.env['omniauth.auth'] }
        }.to_not change(Authorization, :count)
      end
    end
  end

  describe 'GET #verify_email' do
    context 'with valid token' do
      let!(:token) { Devise.friendly_token[0..20] }
      let!(:authorization) {
        create(:authorization, :with_user, confirmed_at: nil, confirmation_token: token)
      }

      before do
        get :verify_email, params: { token: token }
      end

      it 'confirms authorization' do
        expect(authorization.reload).to be_confirmed
      end

      it 'redirects to new session path' do
        expect(response).to redirect_to new_user_session_path
        expect(flash[:notice]).to eq "Your email has been confirmed!"
      end
    end

    context 'with invalid token' do
      let!(:token) { Devise.friendly_token[0..20] }
      let!(:authorization) {
        create(:authorization,
          :with_user,
          confirmed_at: nil,
          confirmation_token: Devise.friendly_token[0..20])
      }

      before do
        get :verify_email, params: { token: token }
      end

      it 'redirects to new root path' do
        expect(response).to redirect_to root_path
        expect(flash[:alert]).to eq "Wrong confirmation token!"
      end
    end
  end
end

require 'rails_helper'

feature 'user can sign in with his Vkontakte account', %q{
  in order to not to create additional account
  as a owner of Vkontakte account
  i'd like to be able to sign in with it
} do
  let!(:user) { create(:user) }

  background do
    visit new_user_session_path
  end

  context 'provider returns valid data' do
    context 'with email' do
      context 'of existing user' do
        scenario 'user tries to sign in' do
          expect(page).to have_content 'Sign in with Vkontakte'
          mock_auth_hash(provider: :vkontakte, email: user.email)
          click_on 'Sign in with Vkontakte'

          expect(page).to have_content 'Successfully authenticated from Vkontakte account.'
          expect(page).to have_content user.email
          expect(page).to have_link 'Log out'
        end
      end

      context 'of no one of existing users' do
        scenario 'user tries to sign in' do
          expect(page).to have_content 'Sign in with Vkontakte'
          mock_auth_hash(provider: :vkontakte, email: 'another@user.com')
          click_on 'Sign in with Vkontakte'

          expect(page).to have_content 'Successfully authenticated from Vkontakte account.'
          expect(page).to have_content 'another@user.com'
          expect(page).to have_link 'Log out'
        end
      end
    end

    context 'without email' do
      scenario 'user follows confirmation instructions' do
        expect(page).to have_content 'Sign in with Vkontakte'
        mock_auth_hash(provider: :vkontakte, email: nil)
        click_on 'Sign in with Vkontakte'

        expect(page).to have_content 'Vkontakte did not provide your email. Please enter your email for sending you confirmation instructions.'
        expect(page).to_not have_link 'Log out'
        fill_in 'oauth_email', with: 'another@user.com'
        click_button 'Confirm email'

        expect(page).to have_content 'A confirmation email has been sent to another@user.com.'

        open_email('another@user.com')
        expect(current_email).to have_content 'another@user.com'
        expect(current_email).to have_link 'Confirm my email'

        current_email.click_link 'Confirm my email'
        expect(page).to have_content 'Your email has been confirmed!'
        expect(page).to_not have_link 'Log out'

        visit new_user_session_path

        expect(page).to have_content 'Sign in with Vkontakte'
        click_on 'Sign in with Vkontakte'

        expect(page).to have_content 'Successfully authenticated from Vkontakte account.'
        expect(page).to have_content 'another@user.com'
        expect(page).to have_link 'Log out'
      end

      scenario 'user tries to log in without confirmation' do
        expect(page).to have_content 'Sign in with Vkontakte'
        mock_auth_hash(provider: :vkontakte, email: nil)
        click_on 'Sign in with Vkontakte'

        expect(page).to have_content 'Vkontakte did not provide your email. Please enter your email for sending you confirmation instructions.'
        expect(page).to_not have_link 'Log out'
        fill_in 'oauth_email', with: 'another@user.com'
        click_button 'Confirm email'

        expect(page).to have_content 'A confirmation email has been sent to another@user.com.'

        visit new_user_session_path

        expect(page).to_not have_link 'Log out'
        expect(page).to have_content 'Sign in with Vkontakte'

        click_on 'Sign in with Vkontakte'

        expect(page).to_not have_link 'Log out'
        expect(page).to have_content 'We have already sent you confirmation instructions to another@user.com. Please check your email.'
      end
    end
  end

  context 'provider returns invalid data' do
    scenario 'user tries to sign in with incorrect Vkontakte account data' do
      expect(page).to have_content 'Sign in with Vkontakte'
      mock_auth_hash(provider: :vkontakte, validness: false)
      click_on 'Sign in with Vkontakte'

      expect(page).to have_content 'Could not authenticate you from Vkontakte because "Invalid credentials"'
      expect(page).to_not have_content 'mockuser@user.com'
      expect(page).to have_link 'Log in'
    end
  end
end

require 'rails_helper'

feature 'user can sign in with his GitHub account', %q{
  in order to not to create additional account
  as a owner of GitHub account
  i'd like to be able to sign in with it
} do
  background { visit visit new_user_session_path }

  scenario 'user tries to sign in with correct GitHub account data' do
    expect(page).to have_content 'Sign in with GitHub'
    mock_auth_hash(provider: :github)
    click_on 'Sign in with GitHub'

    expect(page).to have_content 'Successfully authenticated from GitHub account.'
    expect(page).to have_content 'mockuser@user.com'
    expect(page).to have_link 'Log out'
  end

  scenario 'user tries to sign in with incorrect GitHub account data' do
    expect(page).to have_content 'Sign in with GitHub'
    mock_auth_hash(provider: :github, validness: false)
    click_on 'Sign in with GitHub'

    expect(page).to have_content 'Could not authenticate you from GitHub because "Invalid credentials"'
    expect(page).to_not have_content 'mockuser@user.com'
    expect(page).to have_link 'Log in'
  end
end

require 'rails_helper'

feature 'user can sign in', %q{
  in order to ask questions
  as an unauthenticated user
  i'd like to be able to sign in
} do
  given(:user) { User.create!(email: 'user@test.com', password: '12345678') }

  scenario 'registered user tries to sign in' do
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_on 'Log in'

    expect(page).to have_content 'Signed in successfully.'
  end

  scenario 'unregistered user tries to sign in' do
    visit new_user_session_path
    fill_in 'Email', with: 'wrong@test.com'
    fill_in 'Password', with: '12345678'
    click_on 'Log in'

    expect(page).to have_content 'Invalid Email or password.'
  end
end

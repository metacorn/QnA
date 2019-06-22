require 'rails_helper'

feature 'user can sign up', %q{
  in order to ask questions
  as an authenticated user
  i'd like to be able to sign up
} do
  background { visit new_user_registration_path }

  scenario 'user tries to sign up with valid data' do
    fill_in 'Email', with: 'user@test.com'
    fill_in 'Password', with: '12345678'
    fill_in 'Password confirmation', with: '12345678'
    click_button 'Sign up'

    expect(page).to have_content 'Welcome! You have signed up successfully.'
  end

  scenario 'user tries to sign up with wrong password confirmation' do
    fill_in 'Email', with: 'user@test.com'
    fill_in 'Password', with: '12345678'
    fill_in 'Password confirmation', with: '87654321'
    click_button 'Sign up'

    expect(page).to have_content "Password confirmation doesn't match"
  end

  scenario 'user tries to sign up with invalid email' do
    fill_in 'Email', with: 'user_at_test.com'
    fill_in 'Password', with: '12345678'
    fill_in 'Password confirmation', with: '12345678'
    click_button 'Sign up'

    expect(page).to have_content "Email is invalid"
  end
end

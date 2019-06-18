require 'rails_helper'

feature 'user can create question', %q{
  in order to get answer from a community
  as an authenticated user
  i'd like to be able to ask the question
} do
  given(:user) { User.create!(email: 'user@test.com', password: '12345678') }

  scenario 'authenticated user asks a question' do
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_on 'Log in'

    visit questions_path
    click_on 'Ask a question'

    fill_in 'Title', with: 'Test question title'
    fill_in 'Body', with: "#{"body" * 25}"
    click_on 'Ask'

    expect(page).to have_content 'Your question was successfully created.'
    expect(page).to have_content 'Test question title'
    expect(page).to have_content "#{"body" * 25}"
  end

  scenario 'authenticated user asks a question with errors'

  scenario 'unauthenticated user tries to ask a question' do
    visit questions_path
    click_on 'Ask a question'

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end

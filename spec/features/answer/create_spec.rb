require 'rails_helper'

feature 'user can create answer while being on question page', %q{
  for convenience
  as an authenticated user
  i'd like to be able to answer right on question page
} do
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }

  before do
    login(user)
    visit question_path(question)
  end

  scenario 'answers to a question' do
    fill_in 'Body', with: "#{"body" * 25}"
    click_on 'Leave'

    expect(page).to have_current_path(question_path(question))
    expect(page).to have_content 'Your answer was saved.'
    expect(page).to have_content "#{"body" * 25}"
  end

  scenario 'answers to a question with errors' do
    click_on 'Leave'

    expect(page).to have_current_path(question_path(question))
    expect(page).to have_content 'Your answer was not saved.'
    expect(page).to have_content "Body can't be blank."
    expect(page).to have_content 'Body is too short (minimum is 50 characters).'
  end
end

feature 'only authenticated user can create answers', %q{
  in order to take answers
  as an authenticated user
  i'd like to be able to answer to questions
} do
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }

  scenario 'unauthenticated user tries to ask a question' do
    visit question_path(question)
    fill_in 'Body', with: "#{"body" * 25}"
    click_on 'Leave'

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end

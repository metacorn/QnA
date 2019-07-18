require 'rails_helper'

feature 'user can create answer while being on question page', %q{
  for convenience
  as an authenticated user
  i'd like to be able to answer right on question page
} do
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }

  background do
    login(user)
    visit question_path(question)
  end

  scenario 'answers to a question', js: true do
    fill_in 'answer_body', with: "#{"body" * 25}"
    click_on 'Leave'

    expect(page).to have_content "#{"body" * 25}"
  end

  scenario 'answers to a question with errors', js: true do
    click_on 'Leave'

    expect(page).to have_content "Body can't be blank"
    expect(page).to have_content 'Body is too short (minimum is 50 characters)'
  end

  scenario 'answers to a question with attached files', js: true do
    fill_in 'answer_body', with: "#{"body" * 25}"
    attach_file 'Files', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
    click_on 'Leave'

    expect(page).to have_link "rails_helper.rb"
    expect(page).to have_link "spec_helper.rb"
  end
end

feature 'only authenticated user can create answers', %q{
  in order to take answers
  as an authenticated user
  i'd like to be able to answer to questions
} do
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }

  scenario 'unauthenticated user tries to give an answer' do
    visit question_path(question)
    fill_in 'answer_body', with: "#{"body" * 25}"
    click_on 'Leave'

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end

feature 'created answers shows up at once', %q{
  in order to communicate interactively
  i'd like to see users answers right after their creating
  without refreshing question page
} do
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }

  scenario "all users see new answer in real-time", js: true do
    Capybara.using_session("user") do
      login(user)
      visit question_path(question)
    end

    Capybara.using_session("guest") do
      visit question_path(question)
    end

    Capybara.using_session("user") do
      fill_in 'answer_body', with: "#{"body" * 25}"
      click_on 'Leave'

      expect(page).to have_content "#{"body" * 25}"
    end

    Capybara.using_session("guest") do
      expect(page).to have_content "#{"body" * 25}"
    end
  end
end

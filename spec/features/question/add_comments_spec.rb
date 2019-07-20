require 'rails_helper'

feature 'user can add comments to a question', %q{
  in order to discuss questions
  as an authenticated user
  i'd like to be able to add comments to questions
} do
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }

  scenario 'unauthenticated user can not add comments to questions' do
    visit question_path(question)

    within "#question_#{question.id}" do
      fill_in 'comment_body', with: "#{"body" * 5}"
      click_on 'Add a comment'
    end

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end

  describe 'authenticated user' do
    background do
      login(user)
      visit question_path(question)
    end

    scenario 'adds a comment to a question', js: true do
      within "#question_#{question.id}" do
        fill_in 'comment_body', with: "#{"body" * 5}"
        click_on 'Add a comment'

        expect(page).to have_content "#{"body" * 5}"
      end
    end

    scenario 'tries to add a comment with invalid attributes to a question', js: true do
      within "#question_#{question.id}" do
        fill_in 'comment_body', with: "00000"
        click_on 'Add a comment'

        expect(page).to have_content "Body is too short (minimum is 10 characters)"
      end
    end
  end

  describe 'multiple sessions' do
    scenario "all users see new comments in real-time", js: true do
      Capybara.using_session("user") do
        login(user)
        visit question_path(question)
      end

      Capybara.using_session("guest") do
        visit question_path(question)
      end

      Capybara.using_session("user") do
        within "#question_#{question.id}" do
          fill_in 'comment_body', with: "the first session comment"
          click_on 'Add a comment'
        end
      end

      Capybara.using_session("guest") do
        within "#question_#{question.id}" do
          expect(page).to have_content "the first session comment"
        end
      end
    end
  end
end

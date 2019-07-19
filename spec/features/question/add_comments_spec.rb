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
      click_on 'Add'
    end

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end

  describe 'authenticated user' do
    background do
      login(user)
      visit question_path(question)
    end

    scenario 'adds a comment to question', js: true do
      within "#question_#{question.id}" do
        fill_in 'comment_body', with: "#{"body" * 5}"
        click_on 'Add'

        expect(page).to have_content "#{"body" * 5}"
      end
    end

    scenario 'tries to add a comment with invalid attributes to question', js: true do
      within "#question_#{question.id}" do
        fill_in 'comment_body', with: "00000"
        click_on 'Add'

        expect(page).to have_content "Body is too short (minimum is 10 characters)"
      end
    end
  end
end

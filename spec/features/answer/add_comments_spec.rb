require 'rails_helper'

feature 'user can add comments to an answer', %q{
  in order to discuss answers
  as an authenticated user
  i'd like to be able to add comments to answers
} do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question) { create(:question, user: user1) }
  given!(:answer) { create(:answer, question: question, user: user2) }

  scenario 'unauthenticated user can not add comments to answers' do
    visit question_path(question)

    expect(page).to_not have_link 'Add a comment'
  end

  describe 'authenticated user' do
    background do
      login(user1)
      visit question_path(question)
    end

    scenario 'adds a comment to an answer', js: true do
      within "#answer_#{answer.id}" do
        fill_in 'comment_body', with: "#{"body" * 5}"
        click_on 'Add a comment'

        expect(page).to have_content "#{"body" * 5}"
      end
    end

    scenario 'tries to add a comment with invalid attributes to an answer', js: true do
      within "#answer_#{answer.id}" do
        fill_in 'comment_body', with: "00000"
        click_on 'Add a comment'

        expect(page).to have_content "Body is too short (minimum is 10 characters)"
      end
    end
  end

  describe 'multiple sessions' do
    scenario "all users see new comments in real-time", js: true do
      Capybara.using_session("user") do
        login(user1)
        visit question_path(question)
      end

      Capybara.using_session("guest") do
        visit question_path(question)
      end

      Capybara.using_session("user") do
        within "#answer_#{answer.id}" do
          fill_in 'comment_body', with: "the first session comment"
          click_on 'Add a comment'
        end
      end

      Capybara.using_session("guest") do
        within "#answer_#{answer.id}" do
          expect(page).to have_content "the first session comment"
        end
      end
    end
  end
end

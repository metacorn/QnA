require 'rails_helper'

feature 'user can vote for questions', %q{
  in order to mark an interesting question
  as an authenticated user
  i'd like to be able to vote for questions
} do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question1) { create(:question, user: user1) }
  given(:question2) { create(:question, user: user2) }

  scenario 'unauthenticated user can not vote for questions' do
    visit question_path(question1)

    within "#question_#{question1.id}" do
      expect(page).to_not have_link "Vote"
    end
  end

  describe 'authenticated user' do
    background do
      login(user1)
    end

    scenario "vote for another user's question", js: true do
      visit question_path(question2)

      within "#question_#{question2.id}" do
        expect(page).to have_content 'Votes: - 0 +'

        click_on '+'

        expect(page).to have_content 'Votes: - 1 +'
      end
    end
  end
end

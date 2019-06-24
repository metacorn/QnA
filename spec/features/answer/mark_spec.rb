require 'rails_helper'

feature 'user can mark one answer as the best', %q{
  in order to emphasize the most proper answer
  as an author of a question
  i'd like to be able to mark one of answers to my question as the best
} do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question1) { create(:question, user: user1) }
  given(:question2) { create(:question, user: user2) }
  given!(:answer1) { create(:answer, question: question2, user: user1) }
  given!(:answer2) { create(:answer, question: question1, user: user2) }
  given!(:answer3) { create(:answer, question: question1, user: user2) }

  scenario 'unauthenticated user tries to choose the best answer' do
    visit question_path(question1)

    expect(page).to_not have_link 'Mark as the best'
  end

  describe 'authenticated user', js: true do
    background do
      login(user1)
    end

    scenario 'marks an answer to his question as the best' do
      visit question_path(question1)
      within "#answer_#{answer2.id}" do
        click_on 'Mark as the best'

        expect(page).to have_content 'The best answer'
        expect(page).to_not have_link 'Mark as the best'
      end

      within "#answer_#{answer3.id}" do
        click_on 'Mark as the best'

        expect(page).to have_content 'The best answer'
        expect(page).to_not have_link 'Mark as the best'
      end

      within "#answer_#{answer2.id}" do
        expect(page).to_not have_content 'The best answer'
        expect(page).to have_link 'Mark as the best'
      end
    end

    scenario "tries to mark an answer to another's user question as the best"
  end
end

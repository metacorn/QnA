require 'rails_helper'
require 'byebug'

feature "user can delete his answers but not another's", %q{
  for the sake of order
  as an authenticated user
  i'd like to be able to delete only my own answers
} do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question) { create(:question, user: user1) }

  describe 'authenticated user', js: true do
    background do
      login(user1)
    end

    scenario 'deletes his answer' do
      answer = create(:answer, question: question, user: user1)
      visit question_path(question)
      within "#answer_#{answer.id}" do
        click_on 'Delete'
      end

      expect(page).to_not have_content answer.body
    end

    scenario "tries to delete another's answer" do
      answer = create(:answer, question: question, user: user2)
      visit question_path(question)

      within "#answer_#{answer.id}" do
        expect(page).to_not have_link 'Delete'
      end
    end
  end

  scenario 'unauthenticated user tries to delete an answer' do
    answer = create(:answer, question: question, user: user1)
    visit question_path(question)

    within "#answer_#{answer.id}" do
      expect(page).to_not have_link 'Delete'
    end
  end
end

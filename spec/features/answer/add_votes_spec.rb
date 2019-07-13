require 'rails_helper'

feature 'user can vote for answers', %q{
  in order to mark an interesting answer
  as an authenticated user
  i'd like to be able to vote for answers
} do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question1) { create(:question, user: user1) }
  given(:question2) { create(:question, user: user2) }
  given!(:answer1) { create(:answer, question: question1, user: user2) }
  given!(:answer2) { create(:answer, question: question2, user: user1) }

  scenario 'unauthenticated user can not vote for answers' do
    visit question_path(question1)

    within "#answer_#{answer1.id}" do
      expect(page).to_not have_link "up"
    end
  end

  describe 'authenticated user' do
    background do
      login(user1)
    end

    scenario "vote for another user's answer", js: true do
      visit question_path(question1)

      within "#answer_#{answer1.id}" do
        click_on 'up'

        expect(page).to have_content 'Votes: down 1 up'
      end
    end

    scenario "vote against another user's answer", js: true do
      visit question_path(question1)

      within "#answer_#{answer1.id}" do
        click_on 'down'

        expect(page).to have_content 'Votes: down -1 up'
      end
    end

    scenario "tries to vote for his own answer", js: true do
      visit question_path(question2)

      within "#answer_#{answer2.id}" do
        expect(page).to_not have_link "up"
      end
    end

    scenario "tries to vote against his own answer", js: true do
      visit question_path(question2)

      within "#answer_#{answer2.id}" do
        expect(page).to_not have_link "down"
      end
    end

    scenario "votes, cancels his vote and then revotes", js: true do
      visit question_path(question1)

      within "#answer_#{answer1.id}" do
        click_on 'up'
        click_on 'Cancel'
        click_on 'down'

        expect(page).to have_content 'Votes: down -1 up'
      end
    end
  end
end

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
      expect(page).to_not have_link "up"
    end
  end

  describe 'authenticated user' do
    background do
      login(user1)
    end

    scenario "vote for another user's question", js: true do
      visit question_path(question2)

      within "#question_#{question2.id}" do
        click_on 'up'

        expect(page).to have_content 'Votes: down 1 up'
      end
    end

    scenario "vote against another user's question", js: true do
      visit question_path(question2)

      within "#question_#{question2.id}" do
        click_on 'down'

        expect(page).to have_content 'Votes: down -1 up'
      end
    end

    scenario 'tries to vote for his own question', js: true do
      visit question_path(question1)

      within "#question_#{question1.id}" do
        expect(page).to_not have_link "up"
      end
    end

    scenario 'tries to vote against his own question', js: true do
      visit question_path(question1)

      within "#question_#{question1.id}" do
        expect(page).to_not have_link "down"
      end
    end

    scenario "tries to vote for another user's question twice", js: true do
      visit question_path(question2)

      within "#question_#{question2.id}" do
        click_on 'up'

        expect(page).to_not have_link 'up'
      end
    end

    scenario "tries to vote against another user's question twice", js: true do
      visit question_path(question2)

      within "#question_#{question2.id}" do
        click_on 'down'

        expect(page).to_not have_link 'down'
      end
    end

    scenario "votes, cancels his vote and then revotes", js: true do
      visit question_path(question2)

      within "#question_#{question2.id}" do
        click_on 'down'
        click_on 'Cancel'
        click_on 'up'

        expect(page).to have_content 'Votes: down 1 up'
      end
    end
  end
end

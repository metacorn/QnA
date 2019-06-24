require 'rails_helper'

feature 'user can edit his question', %q{
  in order to correct mistakes
  as an author of an question
  i'd like to be able to edit my question
} do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question1) { create(:question, user: user1) }
  given(:question2) { create(:question, user: user2) }

  scenario 'unauthenticated user can not edit questions' do
    visit question_path(question1)

    within "#question_#{question1.id}" do
      expect(page).to_not have_link "Edit"
    end
  end

  describe 'authenticated user' do
    given(:new_valid_body) { "New question's body #{"c" * 32}" }
    given(:new_invalid_body) { "New question's invalid body" }

    background do
      login(user1)
    end

    scenario 'edits his question', js: true do
      visit question_path(question1)

      within "#question_#{question1.id}" do
        click_on 'Edit'
        fill_in 'question_body', with: new_valid_body
        click_on 'Update'
        sleep(20)

        expect(page).to_not have_content(question1.body)
        expect(page).to have_content new_valid_body
        expect(page).to_not have_selector 'textarea'
      end
    end

    scenario 'try to edit his question with errors'
    scenario "try to edit another user's question"
  end
end

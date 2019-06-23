require 'rails_helper'

feature 'user can edit his answer', %q{
  in order to correct mistakes
  as an author of an answer
  i'd like to be able to edit my answer
} do
  given(:user) { create(:user) }
  given(:user2) { create(:user) }
  given(:question) { create(:question, user: user) }
  given!(:answer) { create(:answer, question: question, user: user) }

  scenario 'unauthenticated user can not edit answers' do
    visit question_path(question)

    expect(page).to_not have_link "Edit"
  end

  describe 'authenticated user' do
    background do
      login(user)
      visit question_path(question)
    end

    given(:new_valid_body) { "New answer's body #{"a" * 32}" }
    given(:new_invalid_body) { "New answer's invalid body" }

    scenario 'edits his answer', js: true do
      within '.answers' do
        click_on 'Edit'
        fill_in 'answer_body', with: new_valid_body
        click_on 'Update'

        expect(page).to_not have_content answer.body
        expect(page).to have_content new_valid_body
        expect(page).to_not have_selector 'textarea'
      end
    end

    scenario 'tries to edit his answer with errors', js: true do
      within '.answers' do
        click_on 'Edit'
        fill_in 'answer_body', with: new_invalid_body
        click_on 'Update'

        expect(page).to have_content answer.body
      end
      expect(page).to have_content 'Body is too short (minimum is 50 characters)'
    end

    scenario "tries to edit another user's answer" do
      click_on 'Log out'
      login(user2)
      visit question_path(question)

      within '.answers' do
        expect(page).to_not have_link 'Edit'
      end
    end
  end
end

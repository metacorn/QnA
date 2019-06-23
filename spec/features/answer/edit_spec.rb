require 'rails_helper'

feature 'user can edit his answer', %q{
  in order to correct mistakes
  as an author of an answer
  i'd like to be able to edit my answer
} do
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }
  given!(:answer) { create(:answer, question: question, user: user) }

  scenario 'unauthenticated user can not edit answers' do
    visit question_path(question)

    expect(page).to_not have_link "Edit the answer"
  end

  describe 'authenticated user' do
    background do
      login(user)
      visit question_path(question)
    end

    given(:new_body) { "New answer's body #{"a" * 32}" }

    scenario 'edits his answer', js: true do
      within '.answers' do
        click_on 'Edit'
        fill_in 'Body', with: new_body
        click_on 'Update'

        expect(page).to_not have_content answer.body
        expect(page).to have_content new_body
        expect(page).to_not have_selector 'textarea'
      end
    end

    scenario 'tries to edit his answer with errors'
    scenario "tries to edit another user's answer"
  end
end

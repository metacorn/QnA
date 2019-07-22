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
  given!(:answer2) { create(:answer, question: question, user: user2) }
  given(:regular_url1) { 'https://google.com' }
  given(:regular_url2) { 'https://yandex.com' }

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
      within "#answer_#{answer.id}" do
        click_on 'Edit'
        fill_in 'answer_body', with: new_valid_body
        click_on 'Update'

        expect(page).to_not have_content answer.body
        expect(page).to have_content new_valid_body
        expect(page).to_not have_selector('textarea', id: 'answer_body')
      end
    end

    scenario 'edits his answer with adding attached files', js: true do
      within "#answer_#{answer.id}" do
        click_on 'Edit'
        attach_file "answer-#{answer.id}-file-upload", ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
        click_on 'Update'

        expect(page).to have_link "rails_helper.rb"
        expect(page).to have_link "spec_helper.rb"
      end
    end

    scenario 'edits his answer with adding links', js: true do
      within "#answer_#{answer.id}" do
        click_on 'Edit'

        click_on 'Add a link'

        within '#new-links .nested-fields:nth-child(1)' do
          fill_in 'Name', with: 'Regular URL #1'
          fill_in 'URL', with: regular_url1
        end

        click_on 'Add a link'

        within '#new-links .nested-fields:nth-child(2)' do
          fill_in 'Name', with: 'Regular URL #2'
          fill_in 'URL', with: regular_url2
        end

        click_on 'Update'

        expect(page).to have_link 'Regular URL #1', href: regular_url1
        expect(page).to have_link 'Regular URL #2', href: regular_url2
      end
    end

    scenario 'tries to edit his answer with errors', js: true do
      within "#answer_#{answer.id}" do
        click_on 'Edit'
        fill_in 'answer_body', with: new_invalid_body
        click_on 'Update'

        expect(page).to have_content answer.body
      end
      expect(page).to have_content 'Body is too short (minimum is 50 characters)'
    end

    scenario "tries to edit another user's answer" do
      within "#answer_#{answer2.id}" do
        expect(page).to_not have_link 'Edit'
      end
    end
  end
end

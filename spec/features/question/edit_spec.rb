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
  given(:regular_url1) { 'https://google.com' }
  given(:regular_url2) { 'https://yandex.com' }

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

        expect(page).to_not have_content(question1.body)
        expect(page).to have_content new_valid_body
        expect(page).to_not have_selector('textarea', id: 'question_body')
      end
    end

    scenario 'edits his question with adding attached files', js: true do
      visit question_path(question1)

      within "#question_#{question1.id}" do
        click_on 'Edit'
        attach_file 'Files', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
        click_on 'Update'

        expect(page).to have_link "rails_helper.rb"
        expect(page).to have_link "spec_helper.rb"
      end
    end

    scenario 'edits his question with adding links', js: true do
      visit question_path(question1)

      within "#question_#{question1.id}" do
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

    scenario 'tries to edit his question with errors', js: true do
      visit question_path(question1)

      within "#question_#{question1.id}" do
        click_on 'Edit'
        fill_in 'question_body', with: new_invalid_body
        click_on 'Update'

        expect(page).to have_content(question1.body)
      end
      expect(page).to have_content 'Body is too short (minimum is 50 characters)'
    end

    scenario "tries to edit another user's question", js: true do
      visit question_path(question2)

      within "#question_#{question2.id}" do
        expect(page).to_not have_link 'Edit'
      end
    end
  end
end

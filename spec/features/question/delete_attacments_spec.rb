require 'rails_helper'

feature "user can delete attachments of his question", %q{
  as an authenticated user
  i'd like to be able to delete only my own questions attachments
} do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given!(:question1) { create(:question, :with_attachments, user: user1) }
  given!(:question2) { create(:question, :with_attachments, user: user2) }

  scenario "unauthenticated user tries to delete question attachments" do
    visit question_path(question1)

    expect(page).to_not have_link 'Delete file'
  end

  context "authenticated user" do
    background do
      login(user1)
    end

    scenario "deletes attached files of his question", js: true do
      visit question_path(question1)

      within "#question_#{question1.id}" do
        click_on 'Delete file'

        expect(page).to_not have_link "rails_helper.rb"
      end
    end

    scenario "deletes attached files of his question" do
      visit question_path(question2)

      within "#question_#{question2.id}" do
        expect(page).to_not have_link "Delete file"
      end
    end
  end
end

require 'rails_helper'

feature "user can delete attachments of his answer", %q{
  as an authenticated user
  i'd like to be able to delete only my own answers attachments
} do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given!(:question1) { create(:question, user: user1) }
  given!(:question2) { create(:question, user: user2) }
  given!(:answer1) { create(:answer,
                            :with_attachments,
                            question: question1,
                            user: user2) }
  given!(:answer2) { create(:answer,
                            :with_attachments,
                            question: question2,
                            user: user1) }

  scenario "unauthenticated user tries to delete answer attachments" do
    visit question_path(question1)

    expect(page).to_not have_link 'Delete file'
  end

  context "authenticated user" do
    background do
      login(user1)
    end

    scenario "deletes attached files of his answer", js: true do
      visit question_path(question2)

      within "#answer_#{answer2.id}" do
        click_on 'Delete file'

        expect(page).to_not have_link "rails_helper.rb"
      end
    end

    scenario "tries to delete attached files of another user's answer" do
      visit question_path(question1)

      within "#answer_#{answer1.id}" do
        expect(page).to_not have_link "Delete file"
      end
    end
  end
end

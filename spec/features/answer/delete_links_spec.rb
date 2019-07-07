require 'rails_helper'

feature "user can delete links of his answer", %q{
  as an authenticated user
  i'd like to be able to delete only my own answers links
} do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question1) { create(:question, user: user1) }
  given(:question2) { create(:question, user: user2) }
  given(:answer1) { create(:answer, question: question2, user: user1) }
  given(:answer2) { create(:answer, question: question1, user: user2) }
  given!(:link1) { create(:link, :valid, linkable: answer1) }
  given!(:link2) { create(:link, :valid_gist, linkable: answer2) }

  scenario "unauthenticated user tries to delete answer links" do
    visit question_path(question1)

    expect(page).to_not have_link 'Delete link'
  end

  context "authenticated user" do
    background do
      login(user1)
    end

    scenario "deletes links of his answer", js: true do
      visit question_path(question2)

      within "#link_#{link1.id}" do
        click_on 'Delete link'

        expect(page).to_not have_link link1.name
      end
    end

    scenario "tries to delete links of another user's question" do
      visit question_path(question1)

      within "#question_#{question1.id}" do
        expect(page).to_not have_link "Delete link"
      end
    end
  end
end

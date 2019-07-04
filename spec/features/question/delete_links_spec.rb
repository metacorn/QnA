require 'rails_helper'

feature "user can delete links of his question", %q{
  as an authenticated user
  i'd like to be able to delete only my own questions links
} do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question1) { create(:question, user: user1) }
  given(:question2) { create(:question, user: user2) }
  given!(:link1) { create(:link, :valid, linkable: question1) }
  given!(:link2) { create(:link, :valid_gist, linkable: question2) }

  scenario "unauthenticated user tries to delete question links" do
    visit question_path(question1)

    expect(page).to_not have_link 'Delete link'
  end

  context "authenticated user" do
    background do
      login(user1)
    end

    scenario "deletes links of his question", js: true do
      visit question_path(question1)

      within "#link_#{link1.id}" do
        click_on 'Delete link'
      end

      expect(page).to_not have_link link1.name
    end

    scenario "tries to delete links of another user's question" do
      visit question_path(question2)

      within "#question_#{question2.id}" do
        expect(page).to_not have_link "Delete link"
      end
    end
  end
end

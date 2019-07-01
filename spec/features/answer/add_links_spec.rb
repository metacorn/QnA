require 'rails_helper'

feature 'user can add links to an answer', %q{
  in order to provide additional info to my answer
  as an answer's author
  i'd like to be able to add links
} do
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }
  given(:gist_url) { 'https://gist.github.com/metacorn/361365b73824b830cded8cd527850bc5' }

  scenario 'user adds a link when get an answer', js: true do
      login user
      visit question_path question

      fill_in 'answer_body', with: "#{"body" * 25}"

      fill_in 'Name', with: 'My gist'
      fill_in 'Url', with: gist_url

      click_on 'Leave'

      within ".answers" do
        expect(page).to have_link 'My gist', href: gist_url
      end
    end
end

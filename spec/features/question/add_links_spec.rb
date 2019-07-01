require 'rails_helper'

feature 'user can add links to a question', %q{
  in order to provide additional info to my question
  as a question's author
  i'd like to be able to add links
} do
  given(:user) { create(:user) }
  given(:gist_url) { 'https://gist.github.com/metacorn/361365b73824b830cded8cd527850bc5' }

  scenario 'user adds a link when asks a question' do
      login user
      visit new_question_path

      fill_in 'Title', with: 'Test question title'
      fill_in 'Body', with: "#{"body" * 25}"

      fill_in 'Name', with: 'My gist'
      fill_in 'Url', with: gist_url

      click_on 'Ask'

      expect(page).to have_link 'My gist', href: gist_url
    end
end

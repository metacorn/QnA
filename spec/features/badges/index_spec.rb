require 'rails_helper'

feature 'user can see his badges', %q{
  in order to provide additional info to my question
  as a question's author
  i'd like to be able to add links
} do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question) { create(:question, user: user2) }
  given(:answer) { create(:answer, question: question, user: user1) }
  given!(:badge) { create(:badge, question: question, answer: answer, user: user1) }

  context 'authenticated user' do
    background do
      login user1
      visit root_path
    end

    scenario 'sees his badges' do
      click_on 'Badges'

      expect(page).to have_content badge.question.title
      expect(page).to have_content badge.name
      expect(page).to have_css "img[src*='badge.png']"
    end
  end

  scenario "unauthenticated user tries to see anyone's badges" do
    visit root_path

    expect(page).to_not have_link 'Badges'
  end
end

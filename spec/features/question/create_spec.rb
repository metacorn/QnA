require 'rails_helper'

feature 'user can create question', %q{
  in order to get answer from a community
  as an authenticated user
  i'd like to be able to ask the question
} do
  given(:user) { create(:user) }

  describe 'authenticated user' do
    background do
      login(user)

      visit questions_path
      click_on 'Ask a question'
    end

    scenario 'asks a question' do
      fill_in 'Title', with: 'Test question title'
      fill_in 'Body', with: "#{"body" * 25}"
      click_on 'Ask'

      expect(page).to have_content 'Your question was successfully created.'
      expect(page).to have_content 'Test question title'
      expect(page).to have_content "#{"body" * 25}"
    end

    scenario 'asks a question with errors' do
      click_on 'Ask'

      expect(page).to have_content "Title can't be blank"
    end

    scenario 'asks a question with attached files' do
      fill_in 'Title', with: 'Test question title'
      fill_in 'Body', with: "#{"body" * 25}"
      attach_file 'Files', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
      click_on 'Ask'

      expect(page).to have_link "rails_helper.rb"
      expect(page).to have_link "spec_helper.rb"
    end

    scenario 'asks a question with setting a badge', js: true do
      fill_in 'Title', with: 'Test question title'
      fill_in 'Body', with: "#{"body" * 25}"

      click_on 'Set a badge'

      within '#new-badge' do
        fill_in 'Name', with: 'Badge name'
        attach_file 'Image', "#{Rails.root}/tmp/images/badge.png"
      end

      click_on 'Ask'

      within '.question' do
        expect(page).to have_css "img[src*='badge.png']"
        expect(page).to have_content "Has a badge \"Badge name\""
      end
    end
  end

  scenario 'unauthenticated user tries to ask a question' do
    visit questions_path

    expect(page).to_not have_link 'Ask a question'
  end
end

feature 'created questions shows up at once', %q{
  in order to communicate interactively
  i'd like to see users questions right after their creating
  without refreshing questions page
} do
  given(:user) { create(:user) }
  given(:question_title) { 'Test question title' }
  given(:question_body) { "#{"body" * 25}" }

  scenario "all users see new question in real-time", js: true do
    Capybara.using_session("user") do
      login(user)
      visit questions_path
    end

    Capybara.using_session("guest") do
      visit questions_path
    end

    Capybara.using_session("user") do
      click_on 'Ask a question'

      fill_in 'Title', with: question_title
      fill_in 'Body', with: question_body

      click_on 'Ask'

      expect(page).to have_content 'Your question was successfully created.'
      expect(page).to have_content question_title
      expect(page).to have_content question_body
    end

    Capybara.using_session("guest") do
      expect(page).to have_link question_title
    end
  end
end

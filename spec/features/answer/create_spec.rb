require 'rails_helper'

feature 'user can create answer while being on question page', %q{
  for convenience
  as an authenticated user
  i'd like to be able to answer right on question page
} do
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }

  background do
    login(user)
    visit question_path(question)
  end

  scenario 'answers to a question', js: true do
    fill_in 'answer_body', with: "#{"body" * 25}"
    click_on 'Leave an answer'

    expect(page).to have_content "#{"body" * 25}"
  end

  scenario 'answers to a question with errors', js: true do
    click_on 'Leave an answer'

    expect(page).to have_content "Body can't be blank"
    expect(page).to have_content 'Body is too short (minimum is 50 characters)'
  end

  scenario 'answers to a question with attached files', js: true do
    fill_in 'answer_body', with: "#{"body" * 25}"
    attach_file 'new-file-upload', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]
    click_on 'Leave an answer'

    expect(page).to have_link "rails_helper.rb"
    expect(page).to have_link "spec_helper.rb"
  end
end

feature 'only authenticated user can create answers', %q{
  in order to take answers
  as an authenticated user
  i'd like to be able to answer to questions
} do
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }

  scenario 'unauthenticated user tries to give an answer' do
    visit question_path(question)

    expect(page).to_not have_link 'Leave an answer'
  end
end

feature 'created answers shows up at once', %q{
  in order to communicate interactively
  i'd like to see users answers right after their creating
  without refreshing question page
} do
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }
  given!(:gist_url) { 'https://gist.github.com/metacorn/361365b73824b830cded8cd527850bc5' }
  given!(:regular_url1) { 'https://google.com' }

  scenario "all users see new answer in real-time", js: true do
    Capybara.using_session("user") do
      login(user)
      visit question_path(question)
    end

    Capybara.using_session("guest") do
      visit question_path(question)
    end

    Capybara.using_session("user") do
      fill_in 'answer_body', with: "#{"body" * 25}"

      attach_file 'new-file-upload', ["#{Rails.root}/spec/rails_helper.rb", "#{Rails.root}/spec/spec_helper.rb"]

      click_on 'Add a link'

      within '#new-links .nested-fields:nth-child(1)' do
        fill_in 'Name', with: 'Regular URL #1'
        fill_in 'URL', with: regular_url1
      end

      click_on 'Add a link'

      within '#new-links .nested-fields:nth-child(2)' do
        fill_in 'Name', with: 'Gist URL'
        fill_in 'URL', with: gist_url
      end

      click_on 'Leave an answer'

      expect(page).to have_content "#{"body" * 25}"
    end

    Capybara.using_session("guest") do
      within ".answers" do
        expect(page).to have_content "#{"body" * 25}"

        expect(page).to have_link 'Regular URL #1', href: regular_url1
        expect(page).to have_content 'Gist URL'
        expect(page).to have_content 'gistfile1.txt'
        expect(page).to have_content 'content of gist_url'

        expect(page).to have_link 'rails_helper.rb'
        expect(page).to have_link 'spec_helper.rb'
      end
    end
  end
end

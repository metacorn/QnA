require 'rails_helper'

feature 'user can add links to a question', %q{
  in order to provide additional info to my question
  as a question's author
  i'd like to be able to add links
} do
  given(:user) { create(:user) }
  given(:gist_url1) { 'https://gist.github.com/metacorn/361365b73824b830cded8cd527850bc5' }
  given(:gist_url2) { 'https://gist.github.com/metacorn/06f8fcade496200f530fdc5e54816b4e' }

  background 'authenticated user' do
    login user
    visit new_question_path
  end

  scenario 'user adds several links when asks a question', js: true do
    fill_in 'Title', with: 'Test question title'
    fill_in 'Body', with: "#{"body" * 25}"

    click_on 'Add a link'

    within '#new-links .nested-fields:nth-child(1)' do
      fill_in 'Name', with: 'My gist #1'
      fill_in 'URL', with: gist_url1
    end

    click_on 'Add a link'

    within '#new-links .nested-fields:nth-child(2)' do
      fill_in 'Name', with: 'My gist #2'
      fill_in 'URL', with: gist_url2
    end

    click_on 'Ask'

    expect(page).to have_link 'My gist #1', href: gist_url1
    expect(page).to have_link 'My gist #2', href: gist_url2
  end

  scenario 'user adds invalid link when asks a question', js: true do
    fill_in 'Title', with: 'Test question title'
    fill_in 'Body', with: "#{"body" * 25}"

    click_on 'Add a link'

    within '#new-links .nested-fields:nth-child(1)' do
      fill_in 'Name', with: 'My gist #1'
      fill_in 'URL', with: 'gist_url1'
    end

    click_on 'Ask'

    expect(page).to have_content 'is an invalid URL'
  end
end

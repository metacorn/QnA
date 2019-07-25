require 'rails_helper'
require "#{Rails.root}/app/services/gist_content.rb"

feature 'user can add links to a question', %q{
  in order to provide additional info to my question
  as a question's author
  i'd like to be able to add links
} do
  given(:user) { create(:user) }
  given(:gist_url) { 'https://gist.github.com/metacorn/361365b73824b830cded8cd527850bc5' }
  given(:regular_url1) { 'https://google.com' }
  given(:regular_url2) { 'https://yandex.com' }

  background 'authenticated user' do
    login user
    visit new_question_path
  end

  scenario 'user adds several links when asks a question', js: true do
    fill_in 'Title', with: 'Test question title'
    fill_in 'Body', with: "#{"body" * 25}"

    click_on 'Add a link'

    within '#new-links .nested-fields:nth-child(1)' do
      fill_in 'Name', with: 'Regular URL #1'
      fill_in 'URL', with: regular_url1
    end

    click_on 'Add a link'

    within '#new-links .nested-fields:nth-child(2)' do
      fill_in 'Name', with: 'Regular URL #2'
      fill_in 'URL', with: regular_url2
    end

    click_on 'Ask'

    expect(page).to have_link 'Regular URL #1', href: regular_url1
    expect(page).to have_link 'Regular URL #2', href: regular_url2
  end

  scenario 'user adds invalid link when asks a question', js: true do
    fill_in 'Title', with: 'Test question title'
    fill_in 'Body', with: "#{"body" * 25}"

    click_on 'Add a link'

    within '#new-links .nested-fields:nth-child(1)' do
      fill_in 'Name', with: 'Regular URL'
      fill_in 'URL', with: 'regular_url'
    end

    click_on 'Ask'

    expect(page).to have_content 'is an invalid URL'
  end

  scenario 'user adds gist link when asks a question', js: true do
    fill_in 'Title', with: 'Test question title'
    fill_in 'Body', with: "#{"body" * 25}"

    click_on 'Add a link'

    within '#new-links .nested-fields:nth-child(1)' do
      fill_in 'Name', with: 'Gist URL'
      fill_in 'URL', with: gist_url
    end

    click_on 'Ask'

    expect(page).to have_content 'Gist URL'
    expect(page).to have_content 'gistfile1.txt'
    expect(page).to have_content 'content of gist_url'
  end
end

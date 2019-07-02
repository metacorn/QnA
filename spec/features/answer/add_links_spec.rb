require 'rails_helper'

feature 'user can add links to an answer', %q{
  in order to provide additional info to my answer
  as an answer's author
  i'd like to be able to add links
} do
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }
  given(:gist_url1) { 'https://gist.github.com/metacorn/361365b73824b830cded8cd527850bc5' }
  given(:gist_url2) { 'https://gist.github.com/metacorn/06f8fcade496200f530fdc5e54816b4e' }

  background 'authenticated user' do
    login user
    visit question_path question
  end

  scenario 'adds several links when gives an answer', js: true do
    fill_in 'answer_body', with: "#{"body" * 25}"

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

    click_on 'Leave'

    within ".answers" do
      expect(page).to have_link 'My gist #1', href: gist_url1
      expect(page).to have_link 'My gist #2', href: gist_url2
    end

    within ".new-answer" do
      expect(page).to_not have_content 'Name'
      expect(page).to_not have_content 'URL'
    end
  end

  scenario 'user adds invalid link when gives an answer', js: true do
    fill_in 'answer_body', with: "#{"body" * 25}"

    click_on 'Add a link'

    within '#new-links .nested-fields:nth-child(1)' do
      fill_in 'Name', with: 'My gist #1'
      fill_in 'URL', with: 'gist_url1'
    end

    click_on 'Leave'

    expect(page).to have_content 'is an invalid URL'
  end
end

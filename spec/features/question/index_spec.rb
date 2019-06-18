require 'rails_helper'

feature 'user can see a list of questions', %q{
  in order to find a question similar to my own
  as a site visitor
  i'd like to see a list of all questions
} do
  given!(:questions) { create_list(:question, 5) }

  scenario 'visitor sees a list of questions' do
    visit questions_path

    expect(page).to have_content "Title of the question #1"
    expect(page).to have_content "Title of the question #2"
    expect(page).to have_content "Title of the question #3"
    expect(page).to have_content "Title of the question #4"
    expect(page).to have_content "Title of the question #5"
  end
end

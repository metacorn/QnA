require 'rails_helper'

feature 'user can create answer while being on question page', %q{
  for convenience
  as an unauthenticated user
  i'd like to be able to answer right on question page
} do
  given(:question) { create(:question) }

  scenario 'unauthenticated user answers to a question' do
    question_path = question_path(question)

    visit question_path
    fill_in 'Body', with: "#{"body" * 25}"
    click_on 'Leave'

    expect(page).to have_current_path(question_path)
  end
end

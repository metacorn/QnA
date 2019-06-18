require 'rails_helper'

feature 'user can see a question and answers to it', %q{
  for convenience
  as an unauthenticated user
  i'd like to see a question and answers together
} do
  before { FactoryBot.reload }
  n = 5

  given!(:question) { create(:question) }
  given!(:answers) { create_list(:answer, n, question: question) }

  scenario 'unauthenticated user sees a question and answers' do
    visit question_path(question)

    expect(page).to have_content "#{"a" * 50}"
    expect(page).to have_content "#{"b" * 50}", count: n
  end
end

require 'rails_helper'

feature 'user can see a question and answers to it', %q{
  for convenience
  as an unauthenticated user
  i'd like to see a question and answers together
} do
  before { FactoryBot.reload }
  n = 5

  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }
  given!(:answers) { create_list(:answer, n, question: question) }

  scenario 'unauthenticated user sees a question and answers', js: true do
    visit question_path(question)

    expect(page).to have_content question.title
    expect(page).to have_content answers.sample.body, count: n
  end
end

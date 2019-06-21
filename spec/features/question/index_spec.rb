require 'rails_helper'

feature 'user can see a list of questions', %q{
  in order to find a question similar to my own
  as a unauthenticated user
  i'd like to see a list of all questions
} do
  before { FactoryBot.reload }
  n = 5

  given(:user) { create(:user) }
  given!(:questions) { create_list(:question, n, user: user) }

  scenario 'unauthenticated user sees a list of questions' do
    visit questions_path

    n.times do |index|
      expect(page).to have_content "Title of the question ##{index + 1}"
    end
  end
end

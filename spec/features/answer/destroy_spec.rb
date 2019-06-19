require 'rails_helper'
require 'byebug'

feature "user can delete his answers but not another's", %q{
  for the sake of order
  as an authenticated user
  i'd like to be able to delete only my own answers
} do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:user3) { create(:user) }
  given(:question) { create(:question, user: user3) }

  before { login(user1) }

  scenario 'user deletes his answer' do
    answer = create(:answer, question: question, user: user1)

    visit question_path(question)
    click_on 'Delete the answer'

    expect(page).to have_content "Your answer was successfully deleted!"
    expect { answer.reload }.to raise_error ActiveRecord::RecordNotFound
  end

  scenario "user tries to delete another's answer" do
    create(:answer, question: question, user: user2)

    visit question_path(question)

    expect(page).to_not have_link 'Delete the answer'
  end
end

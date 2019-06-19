require 'rails_helper'

feature "user can delete his questions but not another's", %q{
  for the sake of order
  as an authenticated user
  i'd like to be able to delete only my own questions
} do
  given(:user1) { create(:user) }
  given(:user2) { create(:user) }
  given(:question1) { create(:question, user: user1) }
  given(:question2) { create(:question, user: user2) }

  before { login(user1) }

  scenario 'user deletes his question' do
    visit question_path(question1)
    click_on 'Delete the question'

    expect(page).to have_content "Your question was successfully deleted!"
  end

  scenario "user tries to delete another's question" do
    visit question_path(question2)

    expect(page).to_not have_content 'Delete the question'
  end
end

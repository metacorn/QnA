require 'rails_helper'
require 'byebug'

feature 'user can log out', %q{
  as an authenticated user
  i'd like to be able to log out
} do
  given(:user) { create(:user) }

  scenario 'authenticated user logs out' do
    login(user)
    visit root_path
    click_on 'Log out'

    expect(page).to have_content("Signed out successfully.")
  end
end

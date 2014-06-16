require 'spec_helper'

feature 'User administration' do

  context 'when signed in as an admin' do
    background { sign_in_as 'admin' }

    scenario 'reviewing the list of users' do
      FactoryGirl.create(:user, umbcusername: 'tom4', group: 'admin')
      FactoryGirl.create(:user, umbcusername: 'jerry9', group: 'lec')

      # typical staff workflow
      visit root_path
      click_on 'Users'

      expect(page).to have_content 'tom4'
      expect(page).to have_content 'jerry9'
    end

    scenario 'creating a new user' do
      visit new_user_path

      fill_in 'Username', with: 'userguy5'
      select 'admin', from: 'Group'

      click_on 'Create'

      expect(current_path).to eq(users_path)
      expect(page).to have_content('successfully created')
      expect(page).to have_content('userguy5')
    end

    scenario "changing a user's group" do
      user = FactoryGirl.create(:user, umbcusername: 'change_my_group', group: 'lec')
      visit users_path
      find_user_row(user).click_link('Edit')

      expect(page).to have_selector('input[value="change_my_group"]')

      select 'admin', from: 'Group'
      click_on 'Update'

      expect(page).to have_content('successfully updated')
      expect(find_user_row(user)).to have_content('admin')
    end

    scenario 'deleting a user' do
      user = FactoryGirl.create(:user, umbcusername: 'deleted_user')
      visit users_path

      find_user_row(user).click_on 'Delete'

      expect(current_path).to eq(users_path)
      expect(page).not_to have_content('deleted_user')
    end
  end

  context 'when not an admin' do
    scenario 'redirect to access denied page' do
      user = FactoryGirl.create(:user)
      sign_in_as 'lec'

      visit users_path
      expect(page).to have_content('Access Denied')

      visit new_user_path
      expect(page).to have_content('Access Denied')

      visit edit_user_path(user)
      expect(page).to have_content('Access Denied')
    end
  end

  def find_user_row(user)
    find("##{user.umbcusername}", '.row')
  end
end
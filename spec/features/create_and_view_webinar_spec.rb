require 'spec_helper'

feature 'new webinar request' do

  context 'user creates a new webinar' do
    background do
      # regular librarians should work too, but
      # login spoof is limited for integration tests
      sign_in_as 'lec'

      visit new_request_path
      fill_request_form_with_valid_data
      create_request
    end

    scenario 'user is shown the request details' do
      expect(current_path).to eq(request_path(Request.last))
      expect(page).to have_content('successfully created')
      expect(page).to have_content('A talking dog')
      expect(page).to have_content('tdog@dmail.com')
      expect(page).to have_content('10:00am to 1:30pm')
      expect(page).to have_content('Mickey Mouse')
      expect(page).to have_content('This webinar will be hosted by a talking dog')
      expect(page).to have_content('http://example.com')
    end

  end

  def fill_request_form_with_valid_data
    fill_in "Requester's name",  with: 'A talking dog'
    fill_in "Requester's email", with: 'tdog@dmail.com'
    select  '10 AM',             from: 'request[start_time(4i)]'
    select  '00',                from: 'request[start_time(5i)]'
    select  '01 PM',             from: 'request[end_time(4i)]'
    select  '30',                from: 'request[end_time(5i)]'
    fill_in 'Sponsor (if any)',  with: 'Mickey Mouse'
    fill_in 'Cost',              with: '500'
    fill_in 'Description',       with: 'This webinar will be hosted by a talking dog'
    fill_in 'Event name',        with: 'Talking Dog etc.'
    fill_in 'URL',               with: 'http://example.com'

    # HACK to get around jquery calendar select magick
    find("input#request_date", :visible=>false).set(Date.today.strftime)
  end

  def create_request
    click_button 'Create'
  end
end
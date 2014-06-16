require 'spec_helper'

feature 'user visits calendar' do

  # set time to May 15, 2013 for consistent tests
  before { Timecop.freeze(2013, 5, 15) }
  after  { Timecop.return }

  given!(:joss) { FactoryGirl.create(:request,
                                     name: 'Joss webinar',
                                     date: Date.today) }
  given!(:bob) { FactoryGirl.create(:request,
                                    name: 'Bobs webinar',
                                    date: Date.today + 30.days) }

  scenario 'the calender does not display unreviewed requests' do
    visit calendar_path
    expect(page).not_to have_content('Joss webinar')
  end

  scenario 'the calendar does not display denied requests' do
    joss.deny
    visit calendar_path
    expect(page).not_to have_content('Joss webinar')
  end

  context 'approved requests' do

    background do
      joss.approve
      bob.approve
      visit calendar_path
    end

    scenario 'displays approved requests as links' do
      expect(page).to have_link('Joss webinar')
    end

    scenario 'displays events in their correct months' do
      expect(page).to have_content('Calendar')
      expect(page).to have_content('Joss webinar')
      expect(page).not_to have_content('Bobs webinar')

      click_link '>'
      expect(page).to have_content('Bobs webinar')
    end


  end
end
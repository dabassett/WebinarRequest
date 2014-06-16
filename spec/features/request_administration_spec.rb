require 'spec_helper'

feature 'Request Administration' do

  context 'when signed in as admin' do
    background { sign_in_as 'admin' }

    context 'request management' do
      given!(:request) do
        FactoryGirl.create(:request,
                           description:    'Dungeons & Dragons',
                           discount:        true,
                           discount_owner: 'Gary Gygax')
      end

      scenario 'looking at event details' do
        visit admin_review_path

        # jquery will hide unselected content
        display = find('div#unreviewed')

        expect(display).to have_content(request.name)
        expect(display).to have_content(request.description)
        expect(display).to have_content(request.url)
        expect(display).to have_content(request.requester)
        expect(display).to have_content(request.requester_email)
        expect(display).to have_content(request.discount_owner) if request.discount
        expect(display).to have_content(request.cost)
        expect(display).to have_content(request.sponsor)
        expect(display).to have_content(request.display_datetime)

      end

      scenario 'approving a new request' do
        visit admin_review_path
        click_on 'Approve'
        expect(find('div#approved')).to have_content(request.description)
      end

      scenario 'denying a new request' do
        visit admin_review_path
        click_on 'Deny'
        expect(find('div#denied')).to have_content(request.description)
      end

      scenario 'deleting a request' do
        visit admin_review_path
        click_on 'Delete'
        expect(page).not_to have_content(request.description)
      end
    end
  end
end
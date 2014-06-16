require 'spec_helper'

describe CalendarController do

  # TODO this could use some refactoring
  describe "GET 'calendar'" do
    context 'variable assigns' do
      before :each do

        @jeff_request = FactoryGirl.build(:request,
                                          requester: 'Jeff Jefferson',
                                          date: Date.today.beginning_of_month + 5.days)
        @ross_request = FactoryGirl.build(:request,
                                          requester: 'Ross Mapleman',
                                          date: Date.today.beginning_of_month + 12.days)
        @unreviewed   = FactoryGirl.build(:request,
                                          requester: 'The Invisible Man',
                                          name: 'An unreviewed request',
                                          date: Date.today.beginning_of_month + 15.days)
        @denied       = FactoryGirl.build(:request,
                                          requester: 'A filthy animal',
                                          name: 'A denied request',
                                          date: Date.today.beginning_of_month + 20.days)


        # HACK avoids 'date set in the past' validation error. brittle
        @jeff_request.save(validate: false)
        @ross_request.save(validate: false)
        @unreviewed.save(validate: false)
        @denied.save(validate: false)

        # approving/denying updates the record automatically
        @jeff_request.approve
        @ross_request.approve
        # @unreviewed gets nothing
        @denied.deny # what a surprise
      end

      it 'assigns webinar objects to @calendar_requests' do
        get 'calendar'
        expect(assigns(:calendar_requests)).to eq([@jeff_request, @ross_request])
      end

      it 'assigns date sorted webinar objects to @calendar_requests_by_date' do
        get 'calendar'
        expect(assigns(:calendar_requests_by_date)[(Date.today.beginning_of_month + 5.days).to_datetime]).to eq([@jeff_request])
      end

      it 'assigns a date object from a parameter' do
        get 'calendar', date: Date.today + 7.days
        expect(assigns(:date)).to be_an_instance_of(Date)
        expect(assigns(:date)).to eq(Date.today + 7.days)
      end
    end

    it 'renders the calendar template' do
      get 'calendar'
      expect(response).to render_template :calendar
    end

  end

end

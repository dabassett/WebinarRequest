class CalendarController < ApplicationController

  before_action(only: [:show]) { |c| c.use_attributes_if_available }

  def calendar
    @calendar_requests = Request.approved
    @calendar_requests_by_date = @calendar_requests.group_by{ |request| request.date.to_datetime}
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
  end
end

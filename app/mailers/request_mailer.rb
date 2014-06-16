class RequestMailer < ActionMailer::Base
  default from: "lits-notification@umbc.edu",
          cc: Proc.new { User.pluck(:mail).compact }

  def confirmation_email(request)
    @request = request
    mail subject: "Webinar Request: Confirmation ##{@request.id}",
         to: @request.requester_email
  end

  def update_email(request)
    @request = request
    mail subject: "Webinar Request: ##{@request.id} was updated",
         to: @request.requester_email
  end

  def delete_email(request)
    @request = request
    mail subject: "Webinar Request: ##{@request.id} was deleted",
         to: @request.requester_email
  end

  def administration_email(request)
    @request = request
    mail subject: "Webinar Request: ##{@request.id} was #{@request.status}",
         cc: nil, to: @request.requester_email
  end
end

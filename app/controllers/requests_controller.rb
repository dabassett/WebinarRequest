class RequestsController < ApplicationController
  before_action :set_webinar_request, only: [:show, :edit, :update, :destroy, :approve, :deny]

  # access control filters
  before_action(only: [:show]) { |c| c.use_attributes_if_available }
  before_action(only: [:new, :create, :my_requests, :old_requests]) { |c| c.require_group_or_attribute([:admin, :lec], :umbcDepartment, 'Library') }
  before_action(only: [:edit, :update, :destroy]) { |c| c.require_group_or_attribute([:admin, :lec], :mail, @request.requester_email) }
  before_action(only: [:review, :approve, :deny]) { |c| c.require_group :admin, :lec }

  # GET /requests
  # GET /requests.json
  def index
    redirect_to calendar_url
  end

  # GET /requests/1
  # GET /requests/1.json
  def show
  end

  # get /my_requests
  def my_requests
     @requests = Request.where("requester_email = ? AND date >= ?",
                               request.env['mail'], Date.today).order(:date)
  end

  # get /old_requests
  def old_requests
    @requests = Request.where("requester_email = ? AND date < ?",
                              request.env['mail'], Date.today).order(:date)
  end

  # GET /requests/new
  def new
    @request = Request.new

    # friendly form defaults
    @request.start_time = Time.zone.local(2000,1,1,9,0,0)
    @request.end_time = Time.zone.local(2000,1,1,12,0,0)
    @request.requester = request.env['displayName']
    @request.requester_email = request.env['mail']
  end

  # GET /requests/1/edit
  def edit
  end

  # POST /requests
  # POST /requests.json
  def create
    @request = Request.new(webinar_request_params)

    respond_to do |format|
      if @request.save
        RequestMailer.confirmation_email(@request).deliver
        format.html { redirect_to @request, notice: 'Webinar request was successfully created.' }
        format.json { render action: 'show', status: :created, location: @request }
      else
        format.html { render action: 'new' }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /requests/1
  # PATCH/PUT /requests/1.json
  def update

    respond_to do |format|
      if @request.update(webinar_request_params)
        RequestMailer.update_email(@request).deliver
        format.html { redirect_to @request, notice: 'Webinar request was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  # administration actions

  # DELETE /requests/1
  # DELETE /requests/1.json
  def destroy
    @request.destroy
    RequestMailer.delete_email(@request).deliver
    respond_to do |format|
      format.html { redirect_to requests_url }
      format.json { head :no_content }
    end
  end

  # get review
  def review
    # SMELL duplication and coupling
    @statuses = %w[unreviewed approved denied]
    @requests_by_status = Request.all.order(:date).group_by(&:status )
    # make sure @request_by_status can't fire nil. Replace with [] instead
    @statuses.each { |status| @requests_by_status[status] ||= [] }
  end

  # patch approve
  def approve
    @request.approve
    RequestMailer.administration_email(@request).deliver
    redirect_to admin_review_url
  end

  # patch deny
  def deny
    @request.deny
    RequestMailer.administration_email(@request).deliver
    redirect_to admin_review_url
  end

  private
    def set_webinar_request
      @request = Request.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def webinar_request_params
      params.require(:request).permit(:requester, :requester_email, :date, :start_time,
                                      :end_time, :sponsor, :cost, :discount, :discount_owner,
                                      :description, :url, :name)
    end
end

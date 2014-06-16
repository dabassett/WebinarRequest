class Request < ActiveRecord::Base
  scope :unreviewed,   -> { where reviewed: false }
  scope :approved,     -> { where reviewed: true, approved: true }
  scope :denied,       -> { where reviewed: true, approved: false }
  scope :date_ordered, ->(direction=:asc) { order date: direction }

  validates :requester, :requester_email, :date, :start_time, :end_time, :cost, :description, :name, presence: true
  validates :requester, :requester_email, :sponsor, :discount_owner, :name, :cost, length: { :maximum => 30 }
  validates :url, :description, length: { :maximum => 500 }
  validate :date_cannot_be_in_the_past, on: :create
  validate :end_time_cannot_be_before_start_time

  # validates requester_email is a valid email address
  validates :requester_email, format: { with: /\A([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})\z/,
                                        message: "isn't a valid email address" }

  # if user indicates that they're including a discount
  #  then require the discount_holder field to be filled
  validates :discount_owner, presence: true, :if => :discount
  validates :discount_owner, absence: true, :unless => :discount

  # validates that a url is valid unless there is no url included
  validates :url, format: { with: /\A(https?:\/\/[\S]+)\z/,
                            message: "isn't a valid URL",
                            allow_blank: true }

  # validates :date is not in the past
  def date_cannot_be_in_the_past
    if date && date < Date.today
      errors.add :date, "can't be set in the past"
    end
  end

  # validates start time is before end time
  def end_time_cannot_be_before_start_time
    if start_time && end_time && start_time >= end_time
      errors.add :start_time, "is set after end time"
    end
  end

  # approve this request
  def approve
    self.reviewed = true
    self.approved = true
    save
  end

  # deny this request
  def deny
    self.reviewed = true
    self.approved = false
    save
  end

  # TODO probably should all go in a decorator

  # report the status of the request
  def status
    if  !self.reviewed && !self.approved
      return 'unreviewed'
    elsif self.reviewed && self.approved
      return 'approved'
    elsif self.reviewed && !self.approved
      return 'denied'
    else return 'undefined'
    end
  end

  # print a friendly datetime for the event
  def display_datetime
    "#{self.start_time.strftime("%-I:%M%P")} to #{self.end_time.strftime("%-I:%M%P")} on #{self.date.strftime("%b %-d, %Y")}"
  end

  def to_s
    self.name
  end
end

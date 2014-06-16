# model spec for webinar request
require 'spec_helper.rb'

describe 'webinar request model' do
  before :each do
    @webinar = FactoryGirl.create(:request)
  end

  # model validations
  context 'valid validation tests' do
    after :each do
      expect(@webinar).to be_valid
    end

    it 'has a valid factory' do
    end
    it 'is valid with a blank url' do
      @webinar.url = ''
    end
    it 'is valid with a somewhat correct url' do
      @webinar.url = 'http://example.com'
    end
    it 'is valid when updating with a date in the past' do
      @webinar.date = 1.month.ago
    end
  end

  context 'invalid validation tests' do
    after :each do
      expect(@webinar).not_to be_valid
    end

    it 'is invalid without a requester' do
      @webinar.requester = ''
    end
    it 'is invalid when requester is too long' do
      @webinar.requester = 'The Pope ' * 5 # limit is 30
    end
    it 'is invalid without a requester email' do
      @webinar.requester_email = ''
    end
    it 'is invalid when requester email is too long' do
      @webinar.requester_email = 'this.email.is.entirely.too.long.for@normal.use' # limit is 30
    end
    it 'is invalid when requester email is not an email address ' do
      @webinar.requester_email = 'Hi there, Im not an email address at all'
    end
    it 'is invalid without a date' do
      @webinar.date = nil
    end
    it 'is invalid without a start time' do
      @webinar.start_time = nil
    end
    it 'is invalid if start time is before end time' do
      @webinar.start_time = @webinar.end_time
    end
    it 'is invalid without an end time' do
      @webinar.end_time = nil
    end
    it 'is invalid when sponsor is too long' do
      @webinar.sponsor = 'Oprah' * 7 # 35 chars, limit is 30
    end
    it 'is invalid without a description' do
      @webinar.description = nil
    end
    it 'is invalid when description is too long' do
      @webinar.description = 'yoloswag' * 100 # 800 chars, limit is 500
    end
    it 'is invalid without a cost' do
      @webinar.cost = nil
    end
    it 'is invalid when discount owner is too long' do
      @webinar.discount = true
      @webinar.discount_owner = 'Oprah' * 7 # 35 chars, limit is 30
    end
    it 'is invalid without a discount holder when discount is selected' do
      @webinar.discount = true
      @webinar.discount_owner = ''
    end
    it 'is invalid when discount is NOT selected and there is a discount holder'  do
      @webinar.discount = false
      @webinar.discount_owner = 'Zalgo; he comes!'
    end
    it 'is invalid when the URL is too long' do
      @webinar.url = "http://itgoeson#{ '.andon' * 100 }" # limit is 500
    end
    it 'is invalid when the URL field contains a bad url' do
      @webinar.url = 'httx://invalid.url.com'
    end
    it 'is invalid without a name' do
      @webinar.name = ''
    end
    it 'is invalid when the name is too long' do
      @webinar.name =  'A thousand pardons!' * 2 # limit 30
    end
  end

  context 'special case' do
    it 'is invalid if the date is in the past (on creation only)' do
      @webinar2 = FactoryGirl.build(:request, date: 1.month.ago)
      expect(@webinar2).not_to be_valid
    end
  end

  # instance methods
  it 'can be approved' do
    @webinar.approve
    @webinar.reload
    expect(@webinar.approved).to be_true
    expect(@webinar.reviewed).to be_true
  end

  it 'can be denied' do
    @webinar.deny
    @webinar.reload
    expect(@webinar.approved).to be_false
    expect(@webinar.reviewed).to be_true
  end

  it 'reports a convenient status' do
    expect(@webinar.status).to eq('unreviewed')
    @webinar.approve
    expect(@webinar.status).to eq('approved')
    @webinar.deny
    expect(@webinar.status).to eq('denied')
  end

  it 'has a convenient datetime display' do
    expect(@webinar.display_datetime).to eq("8:00am to 4:00pm on #{1.month.from_now.strftime("%b %-d, %Y")}")
  end

  it 'writes a friendly name' do
    expect(@webinar.to_s).to eq(@webinar.name)
  end

end
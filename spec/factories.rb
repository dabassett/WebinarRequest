FactoryGirl.define do

  factory :request do
    requester       'Jeff Testguy'
    requester_email 'fake@umbc.edu'
    start_time      Time.gm 2000, 1, 1, 8   # 8:00 am
    end_time        Time.gm 2000, 1, 1, 16  # 4:00 pm
    date            1.month.from_now
    sponsor         'Microsoft'
    cost            '150.00'
    discount        false
    discount_owner  nil
    description     'This is the greatest webinar to ever exist'
    url             'http://some.thing.com'
    approved        false
    reviewed        false
    name            'Jeff\'s webinar'
  end

  factory :invalid_webinar_request, parent: :request do
    requester       nil
  end

  factory :user do
    umbcusername 'auser1'
    group        'lec'
  end
end
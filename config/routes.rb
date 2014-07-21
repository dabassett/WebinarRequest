Webinar::Application.routes.draw do
  mount Shibbolite::Engine => '/shibbolite'

  root 'calendar#calendar'

  resources :requests
  get 'my_requests', to: 'requests#my_requests'
  get 'old_requests', to: 'requests#old_requests'

  resources :users, path: '/admin/users'

  scope '/admin' do
    get 'review', to: 'requests#review', as: 'admin_review'
    patch 'approve/:id', to: 'requests#approve', as: 'approve_request'
    patch 'deny/:id', to: 'requests#deny', as: 'deny_request'
  end

  get 'calendar', to: 'calendar#calendar'

  get 'pages/help', as: 'help'

end

Rails.application.routes.draw do
  # Devise routes with custom paths
  devise_for :users,
    path: '',
    path_names: {
      sign_in: 'login',
      sign_out: 'logout',
      registration: 'signup'
    },
    controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations'
    }

  # API routes
  namespace :api do
    namespace :v1 do
      # Dashboard routes
      get 'dashboard/summary'
      get 'dashboard/net-worth'
      get 'dashboard/cash-flow'
      get 'dashboard/budget-status'

      # Account routes
      resources :accounts do
        get 'statement', on: :member
      end

      # Transaction routes
      resources :transactions

      # Budget routes
      resources :budgets do
        get 'progress', on: :member
      end
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.

  # Defines the root path route ("/")
  # root "posts#index"
end

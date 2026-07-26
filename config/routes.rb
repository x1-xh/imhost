Rails.application.routes.draw do
  devise_for :users

  root "dashboard#index"

  get "/setup", to: "setup#new", as: :setup
  post "/setup", to: "setup#create", as: :setup_create

  resources :uploads do
    member do
      patch :rename
    end
  end

  namespace :admin do
    resources :users
  end

  get "dashboard/index"

  # Custom health check to output exactly "200 OK"
  get "up" => "health#show", as: :rails_health_check
end

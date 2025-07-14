require "resque/server"

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # UI routes (main app interface)
  resources :users, only: [ :new, :create ] do
    collection do
      get :success
      get :login
      post :authenticate
      get :profile
      delete :logout
    end
  end

  # Contact preferences routes
  resource :contact_preferences, only: [ :show, :edit, :update ]

  # Root route can point to signup for now
  root "users#new"
end

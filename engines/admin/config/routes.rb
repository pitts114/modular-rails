Admin::Engine.routes.draw do
  root to: "home#index"
  resources :solutions, only: [ :index, :show ]
  resources :attacks, only: [ :index, :show ]
end

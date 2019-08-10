Rails.application.routes.draw do
  devise_for :users
  resources :businesses do
    member do
      get 'use'
    end
    resources :departments
  end
  resources :user_businesses
end

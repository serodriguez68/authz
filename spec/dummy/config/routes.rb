Rails.application.routes.draw do
  root to: 'visitors#index'

  devise_for :users
  mount Authz::Engine => '/authz', as: :authz
  get 'user_root' => 'reports#index', as: :user_root
  resources :clearances, except: [:show]
  resources :cities, except: [:show]
  resources :reports
  resources :ratings, only: [:index, :new, :create, :destroy]
  resources :announcements, only: [:index, :new, :create, :destroy]
  resources :photos
end

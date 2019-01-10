Rails.application.routes.draw do
  get 'announcements/index'
  get 'announcements/new'
  get 'announcements/create'
  get 'announcements/destroy'
  mount Authz::Engine => '/authz'

  root to: 'visitors#index'

  devise_for :users
  get 'user_root' => 'reports#index', as: :user_root
  resources :clearances, except: [:show]
  resources :cities, except: [:show]
  resources :reports
  # resources :ratings, only: [:index, :new, :create, :destroy]
  resources :announcements
end

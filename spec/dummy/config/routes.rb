Rails.application.routes.draw do
  mount OpinionatedPundit::Engine => '/opinionated_pundit'

  root to: 'visitors#index'

  devise_for :users
  get 'user_root' => 'reports#index', as: :user_root
  resources :clearances, except: [:show]
  resources :cities, except: [:show]
  resources :reports
end

Authz::Engine.routes.draw do

  root 'home#index'
  resources :controller_actions
  resources :business_processes
  resources :roles
  namespace :validations do
    resources :controller_names, only: [:new]
    resources :action_names, only: [:new]
    resources :business_process_names, only: [:new]
    resources :role_names, only: [:new]
  end

  Authz.rolables.each do |rolable|
    resources rolable.authorizable_association_name, only: [:index, :show, :edit, :update], controller: :rolables
  end
end

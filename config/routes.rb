Authz::Engine.routes.draw do

  root 'home#index'
  resources :controller_actions
  resources :business_processes
  resources :roles

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  Authz.rolables.each do |rolable|
    resources rolable.authorizable_association_name, only: [:index, :show, :edit, :update], controller: :rolables
  end


end

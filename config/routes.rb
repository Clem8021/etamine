Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :admins
  get "pages/home"
  root to: "pages#home"

  resources :products, only: [:index, :show]
  resources :orders, only: [:new, :create, :show]
end

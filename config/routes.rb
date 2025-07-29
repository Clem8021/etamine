Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :admins
  get "pages/home"
  root to: "pages#home"

  resources :products, only: [:index, :show]
  resources :orders, only: [:new, :create, :show]
  resources :order_items, only: [:create]

  get "/panier", to: "orders#show", as: :panier
  get '/boutique', to: 'products#index', as: :boutique, defaults: { format: :html }
  patch "/checkout", to: "orders#checkout", as: :checkout
end

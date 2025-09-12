Rails.application.routes.draw do
  # Admin panel
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  # Devise pour les admins (panneau admin uniquement)
  devise_for :admins, path: "admin", controllers: {
    sessions: "admins/sessions"
  }

  # Devise pour les utilisateurs normaux
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords"
  }

  # Pages statiques
  get "pages/home"
  get "/about", to: "pages#about"
  get "/contact", to: "pages#contact"
  get "/cgv", to: "pages#cgv", as: :cgv

  # Racine
  root to: "pages#home"

  # Boutique
  resources :products, only: [:index, :show]

  # Commandes et panier
  resources :orders, only: [:index, :new, :create, :show] do
    member do
      get :checkout   # page récap
      patch :confirm  # validation paiement
    end

    resources :order_items, only: [:create, :destroy]
    resource :delivery_detail, only: [:new, :create, :edit, :update]
  end

  get "/panier", to: "orders#show", as: :panier
  get "/boutique", to: "products#index", as: :boutique, defaults: { format: :html }
  get "/checkout/:id", to: "orders#checkout", as: :checkout
  get "/cart", to: "orders#cart", as: :cart
end

Rails.application.routes.draw do
  get "contacts/create"

  # ======================
  # ADMIN – Dashboard Étamine
  # ======================
  # config/routes.rb
  namespace :backoffice do
    root to: "dashboard#index"
    resources :orders, only: [:index, :show, :update, :destroy]
  end

  # ======================
  # RAILS ADMIN (technique)
  # ======================
  mount RailsAdmin::Engine => '/rails_admin', as: 'rails_admin'

  # === Authentification ===
  devise_for :admins, path: "admin", controllers: {
    sessions: "admins/sessions"
  }

  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords"
  }

  # === Pages statiques ===
  get "pages/home"
  get "/about", to: "pages#about"
  get  "/contact", to: "pages#contact", as: :contact
  post "/contact", to: "pages#contact_submit", as: :contact_submit
  get "/cgv", to: "pages#cgv", as: :cgv

  # Mariage
  get "/mariage",              to: redirect("/mariage/fleuriste"), as: :mariage
  get "/mariage/fleuriste",    to: "pages#mariage_fleuriste",      as: :mariage_fleuriste
  get "/mariage/wedding-design", to: "pages#mariage_wedding",      as: :mariage_wedding

  # === Racine ===
  root to: "pages#home"

  # === Boutique (publique + preview privée)
  get "/boutique", to: "products#index", as: :boutique, defaults: { format: :html }
  get "/boutique-preview", to: "products#preview"
  resources :products, only: [:index, :show]

  # config/routes.rb
  get "/galerie", to: "pages#galerie", as: :galerie

  # === Commandes ===
  resources :orders do
    resources :order_items, only: [:create, :update, :destroy]
    resources :delivery_details, only: [:new, :create, :edit, :update]

    member do
      get :checkout    # étape 1
      post :confirm    # étape 3 (paiement Stripe)
    end

    collection do
      get :success
    end
  end



  get "/cart", to: "orders#cart", as: :cart
  # ✅ Alias simple vers le panier (redirige vers checkout)
  get "/panier", to: redirect("/orders/%{id}/checkout"), as: :panier_redirect

  post "/webhooks/stripe", to: "webhooks/stripe_webhooks#receive"
end

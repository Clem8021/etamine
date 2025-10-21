Rails.application.routes.draw do
  # === Admin panel ===
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

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
  get "/contact", to: "pages#contact"
  get "/cgv", to: "pages#cgv", as: :cgv
  get "/mariage", to: "pages#mariage", as: :mariage

  # === Racine ===
  root to: "pages#home"

  # === Boutique (publique + preview privée)
  get "boutique-preview", to: "products#preview", as: :boutique_preview
  get "/boutique", to: "products#index", as: :boutique, defaults: { format: :html }
  resources :products, only: [:index, :show]

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

  # ⚠️ Supprimé : `get "/cart"` (doublon inutile si checkout existe déjà)
end

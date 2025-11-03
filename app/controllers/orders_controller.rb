class OrdersController < ApplicationController
  before_action :authorize_preview!
  before_action :require_public_or_preview!, only: [:checkout, :confirm, :success]

  # === ADMIN : liste des commandes ===
  def index
    @orders = Order.all.order(created_at: :desc)
    @orders = @orders.where(status: params[:status]) if params[:status].present?
  end

  # === ADMIN ou CLIENT : détail d’une commande ===
  def show
    if current_user.admin?
      @order = Order.find(params[:id])
      render :admin_show and return
    else
      @order = current_user.orders.find_by(id: params[:id])
      if @order.nil?
        redirect_to boutique_path, alert: "Cette commande n'existe pas ou ne vous appartient pas."
        return
      end
      render :show
    end
  end

  # === CRÉATION d’une commande ===
  def create
    @order = current_user.orders.new(order_params.merge(status: "en_attente"))
    if @order.save
      redirect_to checkout_order_path(@order), notice: "🛒 Commande créée avec succès !"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # === ÉTAPE 1 : PANIER / RÉCAPITULATIF ===
  def checkout
    @order = current_user.orders.find(params[:id])

    if @order.order_items.empty?
      redirect_to boutique_path, alert: "Votre panier est vide."
    else
      @ready_for_payment = params[:ready_for_payment].present?
      render :checkout
    end
  end

  # === ÉTAPE 3 : PAIEMENT STRIPE ===
  def confirm
    @order = current_user.orders.find(params[:id])

    if @order.order_items.empty?
      redirect_to checkout_order_path(@order), alert: "Votre panier est vide."
      return
    end

    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: @order.order_items.map do |item|
        {
          price_data: {
            currency: 'eur',
            product_data: { name: item.product.name },
            unit_amount: item.price_cents
          },
          quantity: item.quantity
        }
      end,
      mode: 'payment',
      success_url: success_orders_url(order_id: @order.id),  # ✅ route ajoutée
      cancel_url: checkout_order_url(@order)
    )

    redirect_to session.url, allow_other_host: true
  end

  # === ✅ APRÈS SUCCÈS DU PAIEMENT ===
  def success
    @order = current_user.orders.find(params[:order_id])

    # 1) Marquer payée
    @order.update!(status: "payée")

    # 2) Envoyer les mails AVANT de vider le panier (synchrone = fiable)
    OrderMailer.confirmation_email(@order).deliver_now
    OrderMailer.shop_notification(@order).deliver_now

    # 3) Vider le panier et les détails de livraison
    @order.order_items.destroy_all
    @order.delivery_detail&.destroy

    # 4) Reset session
    session[:order_id] = nil

    redirect_to boutique_path, notice: "🎉 Merci pour votre commande ! Un email de confirmation vous a été envoyé."
  rescue => e
    Rails.logger.error("[Orders#success] Email ou post-traitement raté : #{e.class} - #{e.message}")
    # En cas d'exception, on ne bloque pas le client, on log et on confirme quand même
    redirect_to boutique_path, alert: "Votre paiement a bien été pris en compte, mais l’email n’a pas pu être envoyé immédiatement. Nous allons vérifier cela."
  end

  # === ADMIN : mise à jour du statut ===
  def update
    @order = Order.find(params[:id])
    if current_user.admin?
      if @order.update(order_params)
        redirect_to @order, notice: "Commande mise à jour avec succès."
      else
        render :admin_show, status: :unprocessable_entity
      end
    else
      redirect_to root_path, alert: "Accès réservé à l’administrateur."
    end
  end

  # === PANIER ===
  def cart
    @order = current_order || current_user.orders.create!(status: "en_attente")

    if @order.order_items.empty?
      @order.delivery_detail&.destroy
      session[:order_id] = nil
      redirect_to boutique_path, alert: "Votre panier est vide."
    end
  end

  private

  def order_params
    params.require(:order).permit(:full_name, :email, :address, :status)
  end

  def require_admin!
    redirect_to root_path, alert: "Accès réservé à l’administrateur." unless current_user.admin?
  end
end

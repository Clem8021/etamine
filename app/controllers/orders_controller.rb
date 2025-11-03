class OrdersController < ApplicationController
  # Plus besoin de filtres custom ici : ApplicationController gère l’accès preview.

  # === ADMIN : liste des commandes ===
  def index
    @orders = Order.all.order(created_at: :desc)
    @orders = @orders.where(status: params[:status]) if params[:status].present?
  end

  # === ADMIN ou CLIENT : détail d’une commande ===
  def show
    @order = find_order_for_context
    unless @order
      redirect_to boutique_path, alert: "Cette commande n'existe pas ou ne vous appartient pas."
      return
    end

    if current_user&.admin?
      render :admin_show
    else
      render :show
    end
  end

  # === CRÉATION d’une commande ===
  def create
    if current_user
      @order = current_user.orders.new(order_params.merge(status: "en_attente"))
    else
      # En mode invité on réutilise le panier courant
      @order = current_order
    end

    if @order.persisted? || @order.save
      redirect_to checkout_order_path(@order), notice: "🛒 Commande créée avec succès !"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # === ÉTAPE 1 : PANIER / RÉCAPITULATIF ===
  def checkout
    @order = find_order_for_context
    unless @order
      redirect_to boutique_path, alert: "Commande introuvable."
      return
    end

    if @order.order_items.empty?
      redirect_to boutique_path, alert: "Votre panier est vide."
    else
      @ready_for_payment = params[:ready_for_payment].present?
      render :checkout
    end
  end

  # === ÉTAPE 3 : PAIEMENT STRIPE ===
  def confirm
    @order = find_order_for_context
    unless @order
      redirect_to boutique_path, alert: "Commande introuvable."
      return
    end

    if @order.order_items.empty?
      redirect_to checkout_order_path(@order), alert: "Votre panier est vide."
      return
    end

    session_obj = Stripe::Checkout::Session.create(
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
      success_url: success_orders_url(order_id: @order.id),
      cancel_url: checkout_order_url(@order)
    )

    redirect_to session_obj.url, allow_other_host: true
  end

  # === ✅ APRÈS SUCCÈS DU PAIEMENT ===
  def success
    @order = find_order_for_success
    unless @order
      redirect_to boutique_path, alert: "Commande introuvable."
      return
    end

    @order.update!(status: "payée")

    # Envoi des mails AVANT de vider
    OrderMailer.confirmation_email(@order).deliver_now
    OrderMailer.shop_notification(@order).deliver_now

    # Nettoyage
    @order.order_items.destroy_all
    @order.delivery_detail&.destroy
    session[:order_id] = nil

    redirect_to boutique_path, notice: "🎉 Merci pour votre commande ! Un email de confirmation vous a été envoyé."
  rescue => e
    Rails.logger.error("[Orders#success] Post-traitement raté : #{e.class} - #{e.message}")
    redirect_to boutique_path, alert: "Paiement validé, mais l’email n’a pas pu être envoyé immédiatement."
  end

  # === ADMIN : mise à jour du statut ===
  def update
    @order = Order.find(params[:id])
    if current_user&.admin?
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
    @order = current_order || (current_user&.orders&.create!(status: "en_attente"))

    if @order.order_items.empty?
      @order.delivery_detail&.destroy
      session[:order_id] = nil
      redirect_to boutique_path, alert: "Votre panier est vide."
    end
  end

  private

  # Trouve l’ordre en admin / user / invité (preview)
  def find_order_for_context
    return Order.find(params[:id]) if current_user&.admin?

    if current_user
      # Essaye d’abord l’ordre appartenant à l’utilisateur
      return current_user.orders.find_by(id: params[:id]) ||
             (current_order.id.to_s == params[:id].to_s ? current_order : nil)
    else
      # Invitée : uniquement l’ordre stocké en session
      return current_order if current_order.id.to_s == params[:id].to_s
    end

    nil
  end

  # Pour success (param order_id)
  def find_order_for_success
    return Order.find(params[:order_id]) if current_user&.admin?

    if current_user
      return current_user.orders.find_by(id: params[:order_id]) ||
             (current_order.id.to_s == params[:order_id].to_s ? current_order : nil)
    else
      return current_order if current_order.id.to_s == params[:order_id].to_s
    end

    nil
  end

  def order_params
    params.require(:order).permit(:full_name, :email, :address, :status)
  end
end

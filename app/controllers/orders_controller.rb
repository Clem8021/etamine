# app/controllers/orders_controller.rb
class OrdersController < ApplicationController
before_action :authenticate_user!, only: [:index, :show]
  # app/controllers/orders_controller.rb
  def index
    if current_user
      @orders = current_user.orders.order(created_at: :desc)
                            .where(status: "payée")
                            .order(created_at: :desc)
    else
      redirect_to new_user_session_path, alert: "Veuillez vous connecter pour voir vos commandes."
    end
  end

  # === ADMIN ou CLIENT : détail d’une commande ===
  def show
    @order = find_order_for(params[:id])
    return redirect_to boutique_path, alert: "Commande introuvable." unless @order

    if current_user&.admin?
      render :admin_show
    else
      render :show
    end
  end

  # === CRÉATION d’une commande ===
  def create
    @order =
      if current_user
        current_user.orders.new(order_params.merge(status: "en_attente"))
      else
        current_order
      end

    if @order.persisted? || @order.save
      redirect_to checkout_order_path(@order, key: preview_key_param), notice: "🛒 Commande créée avec succès !"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # === ÉTAPE 1 : PANIER ===
  def checkout
    @order = find_order_for(params[:id])
    unless @order
      redirect_to boutique_path, alert: "Commande introuvable."
      return
    end

    if @order.order_items.empty?
      redirect_to boutique_path, alert: "Votre panier est vide."
      return
    end

    @ready_for_payment = params[:ready_for_payment].present?
    render :checkout
  end

  # === ÉTAPE 3 : PAIEMENT STRIPE ===
  def confirm
    @order = find_order_for(params[:id])
    unless @order
      redirect_to boutique_path, alert: "Commande introuvable."
      return
    end

    if @order.order_items.empty?
      redirect_to checkout_order_path(@order, key: preview_key_param), alert: "Votre panier est vide."
      return
    end

    begin
      session_obj = Stripe::Checkout::Session.create(
        mode: "payment",
        payment_method_types: ["card"],
        line_items: @order.order_items.map { |item| stripe_line_item(item) },
        customer_email: order_customer_email(@order),
        success_url: stripe_success_url(@order),
        cancel_url: stripe_cancel_url(@order),
        metadata: { order_id: @order.id }
      )

      redirect_to session_obj.url, allow_other_host: true

    rescue Stripe::StripeError => e
      Rails.logger.error("[Orders#confirm] StripeError: #{e.class} - #{e.message}")
      redirect_to checkout_order_path(@order, key: preview_key_param),
                  alert: "Une erreur est survenue avec le paiement : #{e.message}"
    rescue => e
      Rails.logger.error("[Orders#confirm] Unexpected error: #{e.class} - #{e.message}")
      redirect_to checkout_order_path(@order, key: preview_key_param),
                  alert: "Impossible de démarrer le paiement pour le moment."
    end
  end

  def edit
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])

    if @order.update(order_params)
      redirect_to orders_path, notice: "✅ Commande mise à jour avec succès."
    else
      flash.now[:alert] = "❌ Impossible de mettre à jour la commande."
      render :edit, status: :unprocessable_entity
    end
  end

  # === ✅ APRÈS SUCCÈS DU PAIEMENT ===
 def success
    @order = Order.find_by(id: params[:order_id])

    unless @order
      redirect_to boutique_path, alert: "Commande introuvable."
      return
    end

    # ⚠️ AUCUNE mise à jour ici
    # ⚠️ AUCUN email ici

    session[:order_id] = nil

    # Simple page de remerciement
    render :success
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

  # Sélection de la commande
  def find_order_for(id_param)
    return Order.find_by(id: id_param.to_i) if current_user&.admin?

    if current_user
      current_user.orders.find_by(id: id_param.to_i) ||
        (current_order.id.to_s == id_param.to_s ? current_order : nil)
    else
      current_order.id.to_s == id_param.to_s ? current_order : nil
    end
  end

  def order_params
    params.require(:order).permit(:full_name, :email, :address, :phone_number)
  end

  def stripe_success_url(order)
    url_for(controller: :orders, action: :success, only_path: false,
            order_id: order.id, key: preview_key_param)
  end

  def stripe_cancel_url(order)
    checkout_order_url(order, key: preview_key_param)
  end

  def preview_key_param
    params[:key].presence
  end

  def stripe_line_item(item)
    name = item.product.name.dup
    name << " - #{item.size}"  if item.respond_to?(:size)  && item.size.present?
    name << " - #{item.color}" if item.respond_to?(:color) && item.color.present?
    name << " (#{Array(item.addons).join(', ')})" if item.respond_to?(:addons) && item.addons.present?

    {
      price_data: {
        currency: "eur",
        product_data: { name: name },
        unit_amount: item.price_cents
      },
      quantity: 1
    }
  end

  def order_customer_email(order)
    return order.user.email if order.user&.email.present?
    return order.delivery_detail.recipient_email if order.delivery_detail&.respond_to?(:recipient_email)

    nil
  end
end

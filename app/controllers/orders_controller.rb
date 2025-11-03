# app/controllers/orders_controller.rb
class OrdersController < ApplicationController
  # L'accès "preview" est déjà géré globalement par ApplicationController.

  # === ADMIN : liste des commandes ===
  def index
    @orders = Order.order(created_at: :desc)
    @orders = @orders.where(status: params[:status]) if params[:status].present?
  end

  # === ADMIN ou CLIENT : détail d’une commande ===
  def show
    @order = find_order_for(params[:id])
    unless @order
      redirect_to boutique_path, alert: "Cette commande n'existe pas ou ne vous appartient pas."
      return
    end

    current_user&.admin? ? render(:admin_show) : render(:show)
  end

  # === CRÉATION d’une commande ===
  def create
    @order =
      if current_user
        current_user.orders.new(order_params.merge(status: "en_attente"))
      else
        # Invitée : on réutilise le panier courant (créé via current_order)
        current_order
      end

    if @order.persisted? || @order.save
      redirect_to checkout_order_path(@order, key: preview_key_param), notice: "🛒 Commande créée avec succès !"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # === ÉTAPE 1 : PANIER / RÉCAPITULATIF ===
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
      # Si la clé Stripe n’est pas présente, on évite une 500 incompréhensible
      unless ENV["STRIPE_SECRET_KEY"].present?
        redirect_to checkout_order_path(@order, key: preview_key_param), alert: "Configuration Stripe manquante."
        return
      end

      session_obj = Stripe::Checkout::Session.create(
        mode: "payment",
        payment_method_types: ["card"],
        # Un peu plus riche côté libellé
        line_items: @order.order_items.map { |item| stripe_line_item(item) },
        # Ça aide Stripe pour les reçus / anti-fraude
        customer_email: order_customer_email(@order),
        success_url: stripe_success_url(@order),
        cancel_url: stripe_cancel_url(@order),
        metadata: {
          order_id: @order.id
        }
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

  # === ✅ APRÈS SUCCÈS DU PAIEMENT ===
  def success
    @order = find_order_for(params[:order_id])
    unless @order
      redirect_to boutique_path, alert: "Commande introuvable."
      return
    end

    @order.update!(status: "payée")

    # On tente les emails, mais on ne bloque pas le client en cas d’échec
    begin
      OrderMailer.confirmation_email(@order).deliver_now
      OrderMailer.shop_notification(@order).deliver_now
    rescue => e
      Rails.logger.error("[Orders#success] Email error: #{e.class} - #{e.message}")
    end

    # Nettoyage panier
    @order.order_items.destroy_all
    @order.delivery_detail&.destroy
    session[:order_id] = nil

    redirect_to boutique_path, notice: "🎉 Merci pour votre commande ! Un email de confirmation vous a été envoyé."
  rescue => e
    Rails.logger.error("[Orders#success] Post-traitement: #{e.class} - #{e.message}")
    redirect_to boutique_path, alert: "Paiement validé, mais une vérification manuelle est nécessaire."
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

  # ——— Sélection de la commande selon le contexte (admin / user / invitée)
  def find_order_for(id_param)
    return Order.find_by(id: id_param) if current_user&.admin?

    if current_user
      current_user.orders.find_by(id: id_param) ||
        (current_order.id.to_s == id_param.to_s ? current_order : nil)
    else
      current_order.id.to_s == id_param.to_s ? current_order : nil
    end
  end

  def order_params
    params.require(:order).permit(:full_name, :email, :address, :status)
  end

  # ——— URLs Stripe (on propage la clé privée si elle est dans l’URL)
  def stripe_success_url(order)
    url_for(controller: :orders, action: :success, only_path: false,
            order_id: order.id, key: preview_key_param)
  end

  def stripe_cancel_url(order)
    checkout_order_url(order, key: preview_key_param)
  end

  def preview_key_param
    # Si tu appelles l’URL privée ?key=..., on la propage (sinon nil → pas ajouté)
    params[:key].presence
  end

  # ——— Infos Stripe
  def stripe_line_item(item)
    # Nom plus parlant si taille / couleur / addons
    name = item.product.name.dup
    name << " - #{item.size}" if item.respond_to?(:size) && item.size.present?
    name << " - #{item.color}" if item.respond_to?(:color) && item.color.present?

    if item.respond_to?(:addons) && item.addons.present?
      addons_txt = Array(item.addons).join(", ")
      name << " (#{addons_txt})"
    end

    {
      price_data: {
        currency: "eur",
        product_data: { name: name },
        unit_amount: item.price_cents
      },
      quantity: item.quantity
    }
  end

  def order_customer_email(order)
    # essaie user.email puis delivery_detail.recipient_email
    return order.user.email if order.respond_to?(:user) && order.user&.email.present?
    if order.respond_to?(:delivery_detail) &&
       order.delivery_detail&.respond_to?(:recipient_email) &&
       order.delivery_detail.recipient_email.present?
      return order.delivery_detail.recipient_email
    end
    nil
  end
end
